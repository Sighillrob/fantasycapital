namespace :projection do
  desc "Fetch data from STATS" 
  task fetch_stats: :environment do
    Rails.logger.info "Feteching and populating Teams from STATS"
    Projection::Team.refresh_all StatsClient::Sports::Basketball::NBA.teams.result
    Rails.logger.info "Feteching and populating Players from STATS"
    Projection::Player.refresh_all StatsClient::Sports::Basketball::NBA.players.result
    Rails.logger.info "Feteching and populating events from STATS"
    Projection::ScheduledGame.refresh_all StatsClient::Sports::Basketball::NBA.events.result
    Rails.logger.info "Feteching and populating Stats from STATS"
    Projection::Player.where(is_current: true).each do |player|
      player.refresh_stats StatsClient::Sports::Basketball::NBA.player_game_by_game_stats(player.stats_player_id).result
    end
  end

  desc "Projeted Fantasy Points"
  task fp: [:environment] do
    Rails.logger.info "Calculating FP..."
    Projection::ScheduledGame.where("start_date > ?", 1.days.ago).each do |scheduled_game|
      [[scheduled_game.home_team, scheduled_game.away_team], [scheduled_game.away_team, scheduled_game.home_team]].each do |(team1, team2)|
        team1.players.each do |player|
          p = Projection::Projection.where(scheduled_game: scheduled_game, player: player).first_or_initialize
          p.fp = Projection::FantasyPointCalculator.new(player).fp(team2)
          p.save!
        end
      end
    end
  end

  desc "Run all tasks needed to build project"
  task run_all: [:environment, :fetch_stats, :fp] do
  end

  desc "Purge projection database"
  task purge: :environment do
    input = ''
    STDOUT.puts "This will delete all data in projectin tables! Are you sure (y/N)?"
    input = STDIN.gets.chomp
    if input.downcase == "y"
      Projection::Projection.delete_all
      Projection::Stat.delete_all
      Projection::GamePlayed.delete_all
      Projection::Game.delete_all
      Projection::ScheduledGame.delete_all
      Projection::Team.delete_all
      Projection::Player.delete_all
    end

  end
end
