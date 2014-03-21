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
#      liveContest['end_at'] = contest.contest_end.utc
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
      # completedContest['complete'] = contest.contest_end.utc.strftime('%Y-%m-%d %H:%M:%S')
      completedContest['entry_fee'] = "$" + contest.entry_fee.to_s
      completedContest['prize'] = "$" + contest.prize.to_s
      completedContest['place'] = 814
      completedContest['won'] = "$0"
      completedContest['results_path'] = entry_path(entry)
      
      completedContests.push(completedContest)
    end

    render json: {liveContests: liveContests, upcomingContests: upcomingContests, completedContests: completedContests}
    
  end


end
