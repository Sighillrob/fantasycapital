class EntriesController < ApplicationController
  def new
    @contest = Contest.find(params[:contest_id])
  end

  def edit
  end

  def show
  end
end
