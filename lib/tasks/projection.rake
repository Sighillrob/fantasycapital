namespace :projection do
  desc "Fetch data from STATS" 
  task fetch_stats: :environment do
    puts "Feteching and populating Teams from STATS"
    Projection::Team.refresh_all StatsClient::Sports::Basketball::NBA.teams.result
    puts "Feteching and populating Players from STATS"
    Projection::Player.refresh_all StatsClient::Sports::Basketball::NBA.players.result
    puts "Feteching and populating Stats from STATS"
    Projection::Player.where(is_current: true).each do |player|
      player.refresh_stats StatsClient::Sports::Basketball::NBA.player_game_by_game_stats(player.stats_player_id).result
    end
  end

  desc "Run all tasks needed to build project"
  task run_all: [:environment, :fetch_stats] do
  end

  desc "Purge projection database"
  task purge: :environment do
    input = ''
    STDOUT.puts "This will delete all data in projectin tables! Are you sure (y/N)?"
    input = STDIN.gets.chomp
    if input.downcase == "y"
      Projection::Stat.delete_all
      Projection::GamePlayed.delete_all
      Projection::Game.delete_all
      Projection::Team.delete_all
      Projection::Player.delete_all
    end

  end
end
