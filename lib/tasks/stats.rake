namespace :stats do
  desc "Populate contests from stats api"
  task fetch_contests: [:environment] do
    response = StatsClient::Sports::Basketball::NBA.sports_for_today
    if response.success?
      response.result.each do |sport|
        #TODO: we'll update this for all sports soon, for now we are focusing on NBA only
        Rails.logger.info "creating contest with stats ID #{sport.id}"
        contest  = Contest.where(stats_id: sport.id).first_or_create
        contest.contest_start = sport.start_date
        contest.sport = 'NBA'
        contest.save
      end

    end
  end
end