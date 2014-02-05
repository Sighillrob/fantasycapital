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

  desc "Populate players for NBA from stats api"
  task fetch_players: [:environment] do
    response = StatsClient::Sports::Basketball::NBA.players
    if response.success?
      response.result.each do |p|
        #TODO: we'll update this for all sports soon, for now we are focusing on NBA only
        Rails.logger.info "creating player with stats ID #{p.id}"
        player  = Player.where(stats_id: p.id).first_or_create
        player.first_name = p.first_name
        player.last_name  = p.last_name
        player.dob        = p.date_of_birth
        player.team       = p.team.name

        if position = p.positions.detect {|pos| p.sequence == 1}
          position.position = position.abbreviation
        end

        player.save
      end

    end
  end

end