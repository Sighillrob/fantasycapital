class ContestsController < ApplicationController
  before_action :set_contest, only: [:show, :edit, :update, :destroy]

  # GET /contests
  # GET /contests.json
  def index
    @contests = current_user.contests
  end

  # GET /contests/browse
  def browse
    @contests = Contest.upcoming
  end

  # GET /contests/1
  # GET /contests/1.json
  def show
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_contest
      @contest = Contest.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def contest_params
      params[:contest]
    end
end
