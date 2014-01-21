class ProjectionsController < ApplicationController
  before_action :set_projection, only: [:show, :edit, :update, :destroy]

  # GET /projections
  def index
    now = Time.now.in_time_zone('America/New_York').beginning_of_day
    time_range = now..(now+1.day)
    @projections = Projection::Projection.includes(:player, scheduled_game: [:home_team, :away_team]).where('projection_scheduled_games.start_date' => time_range)
  end

end
