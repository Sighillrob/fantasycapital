class LineupsController < ApplicationController
  before_action :set_contest, only: [:new, :create]

  def new
    @positions = @contest.sport_positions.where(visible: true).includes(:players).order(display_priority: :asc)
    @lineup     = Lineup.build_for_contest @contest
  end

  def edit
  end

  # POST /entries
  # POST /entries.json
  def create
    @lineup = Lineup.create(line_parameters)
    @lineup.contest = @contest

    respond_to do |format|
      if @lineup.save
        format.html { redirect_to lineups_path, notice: 'Lineup was successfully created.' }
        format.json { render action: 'show', status: :created, location: @lineup }
      else
        @positions = @contest.sport_positions.includes(:players).order(display_priority: :asc)
        format.html { render action: 'new' }
        format.json { render json: @entry.errors, status: :unprocessable_entity }
      end
    end
  end

  def index
    @lineups = Lineup.includes([:lineup_spots, :contest]).order(updated_at: :desc).limit 3
  end

  private
  def set_contest
    @contest = Contest.find(params[:contest_id])
  end

  def line_parameters
    params.require(:lineup).permit(:contest_id, lineup_spots_attributes: [:player_id, :sport_position_id, :spot])
  end
end
