# == Schema Information
#
# Table name: entries
#
#  id         :integer          not null, primary key
#  lineup_id  :integer
#  created_at :datetime
#  updated_at :datetime
#  contest_id :integer
#

class Entry < ActiveRecord::Base
  belongs_to :lineup, inverse_of: :entries
  belongs_to :contest, inverse_of: :entries, counter_cache: true

  has_one :transaction, inverse_of: :entry

  validates :lineup, :contest, presence: true

  validate :number_of_entries
 
  def number_of_entries
    errors.add(:contest, "Number of entries can't exceed maximum.") if contest.entries.count >= contest.max_entries 
  end

  def current_fantasypoints
    # returns total fantasy points of the entry at the moment
    playdate = self.contest.contestdate
    gameids = GameScore.where({playdate: playdate}).pluck('id')
    lineup.players.map { |player| player.realtime_fantasy_points(gameids) }.sum
  end

  def as_json(options = { })
    # add computed parameters for json serialization (for sending to browser)
    h = super(options)
    h[:username]   = self.lineup.user.username
    h[:fps] = self.current_fantasypoints
    # get player_ids sorted by spot in the lineup, so they display in proper order in browser.

    h[:player_ids] = self.lineup.lineup_spots.order('spot').pluck('player_id', 'sport_position_id')
    h
  end

  def games
    # games that this entry is participating in, based on the players, date, and games that day.
    # NOTE: this is expensive to compute; anywhere we can get away with a contest<-->day lookup
    #  instead we should. That won't be totally accurate -- some entries may not use players from
    #  some games.
    team_ids = self.lineup.players.map do |player|
      player.team_id
    end
    games = GameScore.where(playdate:self.contest.contestdate).where('home_team_id IN (?) OR away_team_id IN (?)', team_ids, team_ids)
    games
  end

  def accurate_state
    # return :closed, :in_future, or :live for this entry.
    games = self.games
    statuses = games.map { |game| game.accurate_state }
    return :live if statuses.include?(:live)
    return :closed if !statuses.include?(:in_future)
    return :in_future
  end

  # NILS: BUGBUG: Remove this, relying just on accurate_state?
  def complete?
    # is entry done and over? True if all games are closed. When possible, you should use contest.complete? instead b/c it's cheaper.

    # we will still want this function during game-time, to

    self.games.all? do | game |
      game.closed?
    end
  end

  #def live?
  #  # expensive to compute, b/c list of games is expensive.
  #  self.games.all? do | game |
  #    game.live?
  #  end
  #end

  class << self

    def in_range(start_date, end_date)
      joins(:contest).where "contests.contestdate between ? and ?", start_date, end_date
    end

    def for_sport(sport)
      joins(:contest).where "contests.contests.sport = ?", sport
    end


  end
end
