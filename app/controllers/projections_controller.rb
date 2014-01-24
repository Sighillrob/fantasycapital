class ProjectionsController < ApplicationController
  # GET /projections
  def index
    now = Time.now.in_time_zone('America/New_York').beginning_of_day
    time_range = now..(now+1.day)
    @projections = Projection::Projection.includes(:scheduled_game).where('projection_scheduled_games.start_date' => time_range)
  end

  # GET /projections/with_stats
  def with_stats
    start = Time.parse(params[:date] + " 00:00:00-05:00")
    time_range = start..(start+1.day)
    @projections = Projection::Projection.includes(:projection_by_stats, :scheduled_game => [:home_team, :away_team]).where('projection_scheduled_games.start_date' => time_range)
  end
end
