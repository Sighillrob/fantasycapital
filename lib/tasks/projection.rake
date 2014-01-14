namespace :projection do
  desc "Fetch data from STATS" 
  task fetch_stats: :environment do
    Projection::Team.refresh(StatsClient::Sports::Basketball::NBA.teams.result)
    Projection::Player.refresh(StatsClient::Sports::Basketball::NBA.players.result)
  end

  desc "Run all tasks needed to build project"
  task run_all: [:environment, :fetch_stats] do
  end

end
