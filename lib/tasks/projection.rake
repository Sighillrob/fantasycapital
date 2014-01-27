require 'csv'
require "#{Rails.root}/app/helpers/projection_by_stats_helper"
include ProjectionByStatsHelper
require 'action_view'
include ActionView::Helpers::NumberHelper

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
      :cc => "kenneth.jiang@gmail.com",
      :from => Rails.configuration.projection_notif_email, 
      :subject => "Projection #{today}",
      :html_body => "<h3><a href='http://fantasycapital-stg.herokuapp.com/projections/with_stats?date=#{today}'>Projection #{today}</h3>")
  end

  desc "Generates report that compares projection and actual"
  task review: [:environment] do
    today = Time.now.in_time_zone('America/New_York').beginning_of_day
    time_range = (today-1.day)..today
    projections = Projection::Projection.includes(:player, :projection_by_stats, :scheduled_game).where('projection_scheduled_games.start_date' => time_range)
    event_ids = projections.reduce([]) {|ids, p| ids << p.scheduled_game.stats_event_id}.uniq
    stats = Projection::Stat.includes(:game, :player).where('projection_games.stats_event_id' => event_ids)
    stat_names = ["points", "rebounds", "assists", "steals", "blockedShots", "turnovers"]

    filename = "#{Rails.root}/tmp/review-#{today.strftime('%Y-%m-%d')}.csv"
    CSV.open(filename, "w") do |csv|
      csv << ["Player", "Game", "Projection"].concat( stat_names.inject([]) {|a, s| a << "#{s}(projection)"; a << "#{s}(actual)"})
      projections.each do |proj|
        line = [proj.player.name, proj.scheduled_game.start_date.in_time_zone('America/New_York'), number_with_precision(proj.fp, precision: 2)]
        stat_names.each do |s|
          line << number_with_precision(stat_of(proj, s).fp, precision: 3)
          actual = lookup_stat(stats, proj.scheduled_game.stats_event_id, proj.player, s)
          line << number_with_precision(actual ? actual.stat_value : 0.0, precision: 3)
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
  task run_all: [:environment, :fetch_stats, :fp, :notif, :review] do
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
