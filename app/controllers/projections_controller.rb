class ProjectionsController < ApplicationController
  before_action :set_time_range

  # GET /projections
  def index
    @projections = Projection::Projection.includes(:player, scheduled_game: [:home_team, :away_team]).where('projection_scheduled_games.start_date' => @time_range)
  end

  # GET /projections/with_stats
  def with_stats
    @projections = Projection::Projection.includes(:player, :projection_by_stats, :scheduled_game => [:home_team, :away_team]).where('projection_scheduled_games.start_date' => @time_range)
  end
 
  # GET /projections/review
  def review
    @projections = Projection::Projection.includes(:player, :projection_by_stats, :scheduled_game).where('projection_scheduled_games.start_date' => @time_range)
    event_ids = @projections.reduce([]) {|ids, p| ids << p.scheduled_game.stats_event_id}.uniq
    @stats = Projection::Stat.includes(:game, :player).where('projection_games.stats_event_id' => event_ids)
  end


  private
  def set_time_range
    if params[:date].present?
      start = Time.parse(params[:date] + " 00:00:00-05:00")
    else
      start = Time.now.in_time_zone('America/New_York').beginning_of_day
    end
    @time_range = start..(start+1.day)
  end
end
