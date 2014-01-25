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

  desc "Projet Fantasy Points"
  task fp: [:environment] do
    Rails.logger.info "Calculating FP..."
    c = Projection::FantasyPointCalculator.new
    # load weights and other parameters from rule file
    c.instance_eval(File.read("#{Rails.root}/config/projection_model"), File.read("#{Rails.root}/config/projection_model"))

    Projection::ScheduledGame.where("start_date > ?", 1.days.ago).each do |scheduled_game|
      [[scheduled_game.home_team, scheduled_game.away_team], [scheduled_game.away_team, scheduled_game.home_team]].each do |(team1, team2)|
        team1.players.each do |player|
          p = Projection::Projection.where(scheduled_game: scheduled_game, player: player).first_or_create
          c.update(player, team2, p)
          p.save!
        end
      end
    end
  end

  desc "Send notification email"
  task notif: [:environment] do
    today = Time.now.in_time_zone('America/New_York').strftime("%Y-%m-%d")
    yesterday = (Time.now.in_time_zone('America/New_York') - 1.day).strftime("%Y-%m-%d")
    Pony.mail(
      :to => Rails.configuration.projection_notif_email,
      :from => Rails.configuration.projection_notif_email, 
      :subject => "Projection #{today}",
      :html_body => "<h3><a href='http://fantasycapital-stg.herokuapp.com/projections/with_stats?date=#{today}'>Projection #{today}</h3><h3><a href='http://fantasycapital-stg.herokuapp.com/projections/review?date=#{yesterday}'>Compare to actual: #{yesterday}</h3>")

  end

  desc "Run all tasks needed to build project"
  task run_all: [:environment, :fetch_stats, :fp, :notif] do
  end

  desc "Purge projection database"
  task purge: :environment do
    input = ''
    STDOUT.puts "This will delete all data in projectin tables! Are you sure (y/N)?"
    input = STDIN.gets.chomp
    if input.downcase == "y"
      Projection::ProjectionBreakdown.delete_all
      Projection::ProjByStatCrit.delete_all
      Projection::ProjectionByStat.delete_all
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
