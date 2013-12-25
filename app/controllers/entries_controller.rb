class EntriesController < ApplicationController
  def new
    @contest = Contest.find(params[:contest_id])
    @positions = SportPosition.where(sport: @contest.sport).order(display_priority: :asc)
  end

  def edit
  end

  def show
  end
end
