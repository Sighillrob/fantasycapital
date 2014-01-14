namespace :projection do
  desc "Fetch data from STATS" 
  task fetch_stats: :environment do
    Projection::Team.refresh_all StatsClient::Sports::Basketball::NBA.teams.result
    Projection::Player.refresh_all StatsClient::Sports::Basketball::NBA.players.result
    Projection::Player.where(is_current: true).each do |player|
      player.refresh_stats StatsClient::Sports::Basketball::NBA.player_game_by_game_stats(player.stats_player_id).result
    end
  end

  desc "Run all tasks needed to build project"
  task run_all: [:environment, :fetch_stats] do
  end

end
