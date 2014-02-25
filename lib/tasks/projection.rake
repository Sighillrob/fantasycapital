require 'csv'
require "#{Rails.root}/app/helpers/projection_by_stats_helper"
include ProjectionByStatsHelper
require 'action_view'
include ActionView::Helpers::NumberHelper

namespace :projection do
  desc "Fetch data from external source (SportsData)" 
  task fetch_stats: :environment do
    Rails.logger.info "Feteching and populating Teams from SportsData"
    teams = Projection::Team.refresh_all SportsdataClient::Sports::NBA.teams.result

    Rails.logger.info "Feteching and populating Players from SportsData"
    teams.each do |team|
      Projection::Player.refresh SportsdataClient::Sports::NBA.players(team.ext_team_id).result, team
    end

    Rails.logger.info "Feteching and populating Games from SportsData"
    cutoff = ENV['cutoff'] || "10"
    games = Projection::Game.refresh_all(
        ( SportsdataClient::Sports::NBA.regular_season_games.result + SportsdataClient::Sports::NBA.post_season_games.result ),
      Time.now - cutoff.to_i.days
    )

    Rails.logger.info "Feteching and populating Player stats from SportsData"
    games.each do |game|
      game.refresh_stats SportsdataClient::Sports::NBA.game_stats(game.ext_game_id).result
    end
        
    Rails.logger.info "Feteching and populating scheduled games from SportsData"
    Projection::ScheduledGame.refresh_all SportsdataClient::Sports::NBA.games_scheduled.result
  end

  desc "Projet Fantasy Points"
  task fp: [:environment] do
    Rails.logger.info "Calculating FP..."
    Projection::ScheduledGame.where("start_date > ?", 1.days.ago).each do |scheduled_game|
      Projection::FantasyPointCalculator.new.update scheduled_game
    end
  end

  desc "Send notification email"
  task notif: [:environment] do
    today = Time.now.in_est.strftime("%Y-%m-%d")
    yesterday = (Time.now.in_est - 1.day).strftime("%Y-%m-%d")
    Pony.mail(
      :to => Rails.configuration.projection_notif_email,
      :cc => "kenneth.jiang@gmail.com",
      :from => Rails.configuration.projection_notif_email, 
      :subject => "Projection #{today}",
      :html_body => "<h3><a href='http://fantasycapital-stg.herokuapp.com/projections/with_stats?date=#{today}'>Projection #{today}</h3>")
  end

  desc "Generates report that compares projection and actual"
  task review: [:environment] do
    today = Time.now.in_est.beginning_of_day
    time_range = (today-1.day)..today
    projections = Projection::Projection.includes(:player, :projection_by_stats, :scheduled_game).where('projection_scheduled_games.start_date' => time_range)
    event_ids = projections.reduce([]) {|ids, p| ids << p.scheduled_game.stats_event_id}.uniq
    stats = Projection::Stat.includes(:game, :player).where('projection_games.stats_event_id' => event_ids)
    stat_names = Projection::Stat::STATS_ALLOWED.keys - ["minutes"]

    filename = "#{Rails.root}/tmp/review-#{today.strftime('%Y-%m-%d')}.csv"
    CSV.open(filename, "w") do |csv|
      csv << ["Player", "Game", "Projection"].concat( stat_names.inject([]) {|a, s| a << "#{s}(projection)"; a << "#{s}(actual)"})
      projections.each do |proj|
        line = [proj.player.name, proj.scheduled_game.start_date.in_time_zone('America/New_York'), "%.2f" % proj.fp]
        weighted_actual = Projection::FantasyPointCalculator.new.weighted_fp do |s, weight|
          lookup_stat(stats, proj.scheduled_game.stats_event_id, proj.player, s).stat_value rescue 0.0
        end
        line << "%.2f" % weighted_actual
        stat_names.each do |s|
          line << "%.3f" % stat_of(proj, s).fp
          actual = lookup_stat(stats, proj.scheduled_game.stats_event_id, proj.player, s)
          line << "%.2f" % (actual ? actual.stat_value : 0.0)
        end
        csv << line
      end
    end

    Pony.mail(
      :to => Rails.configuration.projection_notif_email,
      :cc => "kenneth.jiang@gmail.com",
      :from => Rails.configuration.projection_notif_email, 
      :subject => "Review #{today}",
      :html_body => "<h3>#{today}</h3>",
      :attachments => {"review-#{today.strftime('%Y-%m-%d')}.csv" => File.read(filename)}
    )
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
