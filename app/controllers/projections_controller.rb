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
 
  # GET /projections/stats_by_game
  def stats_by_game
    @games_played = Projection::GamePlayed.includes(:player, :game).where( player_id: params['player_id'])
  end

  private
  def set_time_range
    if params[:date].present?
      start = Time.parse(params[:date] + " 00:00:00-05:00")
    else
      start = Time.now.in_est.beginning_of_day
    end
    @time_range = start..(start+1.day)
  end
end
