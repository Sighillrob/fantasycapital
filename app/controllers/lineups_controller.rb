class LineupsController < ApplicationController
  before_action :set_contest, only: [:new, :create, :edit, :update]
  before_action :set_lineup, only: [:edit, :update]

  def new
    @positions = @contest.sport_positions.where(visible: true).includes(:players).order(display_priority: :asc)
    @lineup     = Lineup.build_for_contest @contest
  end

  def edit
    @positions = @lineup.contest.sport_positions.where(visible: true).includes(:players).order(display_priority: :asc)
  end

  # POST /entries
  # POST /entries.json
  def create
    @lineup = Lineup.create(lineup_parameters)
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

  # PATCH /entries
  # PATCH /entries.json
  def update 
    @lineup.contest = @contest

    respond_to do |format|
      if @lineup.update(lineup_parameters)
        format.html { redirect_to lineups_path, notice: 'Lineup was successfully updated.' }
        format.json { render action: 'show', status: :created, location: @lineup }
      else
        @positions = @contest.sport_positions.includes(:players).order(display_priority: :asc)
        format.html { render action: 'edit' }
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

  def set_lineup
    @lineup = Lineup.find(params[:id])
  end

  def lineup_parameters
    params.require(:lineup).permit(:contest_id, lineup_spots_attributes: [:player_id, :id, :sport_position_id, :spot])
  end
end
