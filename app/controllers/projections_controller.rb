class ProjectionsController < ApplicationController
  before_action :set_projection, only: [:show, :edit, :update, :destroy]

  # GET /projections
  def index
    @projections = Projection::Projection.includes(:player, scheduled_game: [:home_team, :away_team]).where("updated_at > ?", 1.day.ago)
  end

end
