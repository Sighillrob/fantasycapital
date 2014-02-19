class ApiController < ApplicationController
	respond_to :json

	def searchEntries
    entries = current_user.entries
    liveContests = entries.live.present ? entries.live : nil
    upcomingContests = entries.upcoming.present ? entries.upcoming : nil
    completedContests = entries.completed.present ? entries.completed : nil

    respond_to do |format|
      format.json {render json: {liveContests: liveContests, upcomingContests: upcomingContests, completedContests: completedContests}}
    end
  end
end
