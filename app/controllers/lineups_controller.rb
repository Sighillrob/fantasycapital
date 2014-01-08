class LineupsController < ApplicationController
  before_action :set_contest, except: :index
  before_filter :authenticate_user!
  before_action :set_lineup, only: [:edit, :update]

  def new
    @positions = @contest.sport_positions.where(visible: true).includes(:players).order(display_priority: :asc)
    @lineup    = Lineup.build_for_contest @contest
  end

  def edit
    @positions = @contest.sport_positions.where(visible: true).includes(:players).order(display_priority: :asc)
    @lineup    = current_user.lineups.build_for_contest @contest, params[:id]
  end

  def result

  end

  # POST /entries
  # POST /entries.json
  def create
    @lineup         = current_user.lineups.create(lineup_parameters)
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
    @lineups = current_user.lineups.includes([:lineup_spots, :contest]).order(updated_at: :desc).limit 3
  end

  def update
   @lineup = current_user.lineups.find(params[:id])

   respond_to do |format|
     if @lineup.update_attributes(lineup_parameters)
       format.html { redirect_to lineups_path, notice: 'Lineup was successfully updated.' }
       format.json { render action: 'show', status: :created, location: @lineup }
     else
       @positions = @contest.sport_positions.includes(:players).order(display_priority: :asc)
       format.html { render action: 'edit' }
       format.json { render json: @entry.errors, status: :unprocessable_entity }
     end
   end

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
