require 'csv'
require "#{Rails.root}/app/helpers/projection_by_stats_helper"
include ProjectionByStatsHelper
require 'action_view'
include ActionView::Helpers::NumberHelper

SPORTS = {NBA: {api_client: SportsdataClient::Sports::NBA},
          #MLB: {api_client: SportsdataClient::Sports::MLB}
}

namespace :projection do
  desc "Fetch data from external source (SportsData)" 
  task fetch_stats: :environment do
    SPORTS.each do |sport_name, sport|

      Rails.logger.info "Feteching and populating Teams from SportsData"
      teams = Projection::Team.refresh_all sport[:api_client].teams.result

      Rails.logger.info "Fetching and populating Players from SportsData"
      teams.each do |team|
        Projection::Player.refresh sport[:api_client].players(team.ext_team_id).result, team
      end

      Rails.logger.info "Fetching and populating Games from SportsData"
      cutoff = ENV['cutoff'] || "10"
      gamelist = sport[:api_client].all_season_games
      games = Projection::Game.refresh_all(sport_name.to_s, gamelist, Time.now - cutoff.to_i.days)

      Rails.logger.info "Fetching and populating Player stats from SportsData"
      games.each do |game|
        game.refresh_stats sport[:api_client].game_stats(game.ext_game_id).result
      end

      Rails.logger.info "Fetching and populating scheduled games from SportsData"
      Projection::ScheduledGame.refresh_all sport[:api_client].games_scheduled.result
    end

  end

  desc "Project Fantasy Points"
  task fp: [:environment] do
    Rails.logger.info "Calculating FP..."
    Projection::ScheduledGame.games_on.each do |scheduled_game|
      Resque.enqueue(FPCalculationWorker, scheduled_game.id)
    end
  end

  desc "Send notification email"
  task notif: [:environment] do
    today = Time.now.in_time_zone("EST").strftime("%Y-%m-%d")
    yesterday = (Time.now.in_time_zone("EST") - 1.day).strftime("%Y-%m-%d")
    Pony.mail(
      :to => Rails.configuration.projection_notif_email,
      :cc => "kenneth.jiang@gmail.com",
      :from => Rails.configuration.projection_notif_email, 
      :subject => "Projection #{today}",
      :html_body => "<h3><a href='http://fantasycapital-stg.herokuapp.com/projections/with_stats?date=#{today}'>Projection #{today}</h3>")
  end

  desc "Generates report that compares projection and actual"
  task review: [:environment] do
    stat_names = Projection::Stat::STATS_ALLOWED.keys - ["minutes", "personal_fouls", "fp"]

    today = Time.now.in_time_zone("EST").beginning_of_day
    time_range = (today-3.day)..today
    projections = Projection::Projection.includes(:player, :projection_by_stats, :scheduled_game).where('projection_scheduled_games.start_date' => time_range)

    filename = "#{Rails.root}/tmp/review-#{today.strftime('%Y-%m-%d')}.csv"
    CSV.open(filename, "w") do |csv|
      csv << ["Player", "Game", "fp(projection)", "fp(actual)"].concat( stat_names.inject([]) {|a, s| a << "#{s}(projection)"; a << "#{s}(actual)"})
      projections.each do |proj|
        player = proj.player
        game = Projection::Game.where(ext_game_id: proj.scheduled_game.ext_game_id, team: player.team).first
        next if game.nil?

        actual_fp = Projection::Stat.where(game: game, player: player, stat_name: "fp").first.try(:stat_value) || 0.0
        line = [proj.player.name, proj.scheduled_game.start_date.in_time_zone('EST'), "%.2f" % (proj.fp || 0.0), "%0.2f" % actual_fp]
        stat_names.each do |s|
          line << "%.3f" % (stat_of(proj, s).try(:fp) || 0.0)
          actual = Projection::Stat.where(game: game, player: player, stat_name: s).first
          line << "%.2f" % (actual ? actual.stat_value : 0.0)
        end
        csv << line
      end
    end

    Pony.mail(
      :to => Rails.configuration.projection_notif_email,
      :cc => "techalerts@fantasycapital.com",
      :from => Rails.configuration.projection_notif_email, 
      :subject => "Review #{today}",
      :html_body => "<h3>#{today}</h3>",
      :attachments => {"review-#{today.strftime('%Y-%m-%d')}.csv" => File.read(filename)}
    )
  end

  desc "Purge projection database"
  task purge: :environment do
    input = ''
    STDOUT.puts "This will delete all data in projection tables! Are you sure (y/N)?"
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

desc "Run all tasks needed to build project"
task projection: [:environment, "projection:fetch_stats", "projection:fp", "projection:notif", "projection:review"]
