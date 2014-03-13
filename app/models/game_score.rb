class GameScore < ActiveRecord::Base
  belongs_to :home_team, :class_name => 'Team'
  belongs_to :away_team, :class_name => 'Team'

  # games can have one of these status's (from the external API):
  #scheduled - The game is scheduled to occur.
  #created – The game has been created and we have begun logging information.
  #inprogress – The game is in progress.
  #halftime - The game is currently at halftime.
  #complete – The game is over, but stat validation is not complete.
  #closed – The game is over and the stats have been validated.
  #cancelled – The game has been cancelled.
  #delayed – The start of the game is currently delayed or the game has gone from in progress to delayed
  #for some reason.
  #postponed – The game has been postponed, to be made up at another day and time.
  #time-tbd – The game has been scheduled, but a time has yet to be announced.
  #unnecessary – The series game was scheduled to occur, but will not take place due to one team
  #clinching the series early.

  # status indications that aren't an exception:
  GOOD_STATUSES = ['scheduled', 'time-tbd', 'created', 'inprogress', 'halftime', 'complete', 'closed',
                   'delayed']
  IN_PROGRESS_STATUSES = ['created', 'inprogress', 'halftime', 'delayed']

  IN_FUTURE_STATUSES = ['scheduled', 'time-tbd']
  ## game is no longer playing live.
  #def ended?
  #  actualend != nil || exception_ending
  #end

  def in_future?
    IN_FUTURE_STATUSES.include?(status)
  end


  def in_prog?
    IN_PROGRESS_STATUSES.include?(status)
  end

  def exception_ending?
    # did game finish with an exception condition? (ie no final scores?)
    !GOOD_STATUSES.include?(status)
  end
  # game is over and done, including final scores if it completed successfully
  def closed?
    (self.status=='closed') || exception_ending?
  end
  # scores are valid (ie game finished successfully and we've got final data)
  def scores_valid?
    (self.status=='closed') && !exception_ending?
  end

  # Minutes left in play. Hardcoded to NBA for now, this is different for college basketball
  # and other sports!
  def minutes_remaining
    # NBA has 4 12-minute periods
    48 - (12 * (self.period - 1) + self.clock)
  end

  # pretty-printed play state for user, ie "5 min left" or "FINAL" or "scheduled" (if scheduled)
  def pretty_play_state
    if scores_valid?
      "FINAL"
    elsif exception_ending?
      "CANCELLED"
    elsif in_prog?
      "#{minutes_remaining} MIN LEFT"
    else
      "SCHEDULED"   # remaining states should all map to scheduled... if not, we'll learn :)
    end


  end
  # record game status for this game from sportsdata API (sportsdata 'game-summary' data)
  def record_sportsdata (game_summary, game_src)
    # get realtime stats on any game that is in progress and hasn't been resolved in our DB yet.
    # games are only resolved in our DB once they are "closed" from the external API, or if
    # some other exception (like 'postponed', 'unnecessary', 'cancelled') happens.
    return if game_summary['status'] == 'scheduled'  # game hasn't started yet - nothing to update.
    return if closed?  # we're done with this game, no changes made.
    if !exception_ending?
      # good status
      self.period=game_src['quarter'].to_i  # NBA, a period is a quarter
      self.clock=game_src['clock'].to_i
      self.home_team_score=game_src['team'][0]['points'].to_i  # BUGBUG: Not sure if [0] is always home
      self.away_team_score=game_src['team'][1]['points'].to_i
    end
    # record status at end of update so we still capture one 'closed' state.
    self.status = game_summary['status']

  end

end
