class ApiController < ApplicationController
	respond_to :json

	def searchEntries
    entries = current_user.entries
    liveEntries = entries.live
    upcomingEntries = entries.upcoming
    completedEntries = entries.completed

    liveContests = []
    liveEntries.each do |entry|
      liveContest = {}

      contest = Contest.find_by_id(entry.contest_id)
      liveContest['id'] = contest.id
      liveContest['sport'] = contest.sport
      liveContest['start_at'] = contest.contest_start.utc.strftime('%Y-%m-%d %H:%M:%S')
      liveContest['end_at'] = contest.contest_end.utc
      liveContest['entry_fee'] = contest.entry_fee
      liveContest['prize'] = contest.prize
      liveContest['place'] = 814
      liveContest['results_path'] = entry_path(entry)
 
      liveContests.push(liveContest)
    end

    upcomingContests = []
    upcomingEntries.each do |entry|
      upcomingContest = {}

      contest = Contest.find_by_id(entry.contest_id)
      upcomingContest['id'] = contest.id
      upcomingContest['sport'] = contest.sport
      upcomingContest['start_at'] = contest.contest_start.utc
      upcomingContest['entry_fee'] = contest.entry_fee
      upcomingContest['prize'] = contest.prize
      upcomingContest['entry_size'] = contest.entries.size
      upcomingContest['edit_path'] = edit_lineup_path(Lineup.find_by_id(entry.lineup_id))
      upcomingContest['view_path'] = entry_path(entry)

      upcomingContests.push(upcomingContest)
    end

    completedContests = []    
    completedEntries.each do |entry|
      completedContest = {}

      contest = Contest.find_by_id(entry.contest_id)
      completedContest['id'] = contest.id
      completedContest['sport'] = contest.sport
      completedContest['complete'] = contest.contest_end.utc.strftime('%Y-%m-%d %H:%M:%S')
      completedContest['entry_fee'] = "$" + contest.entry_fee.to_s
      completedContest['prize'] = "$" + contest.prize.to_s
      completedContest['place'] = 814
      completedContest['won'] = "$0"
      completedContest['results_path'] = entry_path(entry)
      
      completedContests.push(completedContest)
    end

    render json: {liveContests: liveContests, upcomingContests: upcomingContests, completedContests: completedContests}
    
  end

  def gc_data
    # get AJAX data for an Entry identified by entry_id, to populate gamecenter.

    entry = {}
    contest = {}
    lineup = {}
    lineup_spots = []
    users = []
    my = []
    teams = {}

    entry_id = params[:entry_id]
    entry = Entry.find_by_id(entry_id)

    # create hash of team-id to game-ids of relevant games, used by browser to map scores
    # to players.
    GameScore.recent_and_upcoming.all.each { |game|
      teams[game.home_team.id] = teams[game.away_team.id] = {game: game.id}
    }

      unless entry.nil?
      #contest['id'] = entry.contest.id
      #contest['sport'] = entry.contest.sport
      #contest['start_at'] = entry.contest.contest_start.utc.strftime('%Y-%m-%d %H:%M:%S')
      #contest['end_at'] = entry.contest.contest_end.utc
      #contest['entry_fee'] = entry.contest.entry_fee
      #contest['prize'] = entry.contest.prize
      #contest['place'] = 814

      #users = contest.users
      lineup = entry.lineup
      my = lineup.user
      curr_fp = entry.current_fantasypoints
      lineup.lineup_spots.each do |lineup_spot|
        ls = {}
        ls['player'] = lineup_spot.player
        ls['sport_position'] = lineup_spot.sport_position

        stats = {}
        ["points", "assists", "steals", "rebounds", "blocks", "turnovers", "minutes", "fp"].each do |stat_name|
          stats[stat_name] = 0
        end

        ls['score'] = 0
        ls['stats'] = stats
        rt_scores = PlayerRealTimeScore.where(player: lineup_spot.player)
        rt_scores.each do |score|
          ls['stats'][score.name] = score.value.floor
          ls['score'] += score.value.floor
        end

        lineup_spots.push(ls)
      end

    end

    render json: {contest: contest, entry: entry, users: users, lineup: lineup,
                  lineup_spots: lineup_spots, my: my, curr_fp:curr_fp,
                  teams: teams
                  }
  end

end
