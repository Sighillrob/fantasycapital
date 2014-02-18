class LineupsController < ApplicationController
  before_filter :authenticate_user!
  before_action :set_lineup, only: [:edit, :update]

  def new
    @contest = Contest.find(params[:contest_id])
    @lineup    = Lineup.build_for_contest @contest
    @positions = SportPosition.where(sport: @lineup.sport, visible: true).includes(:players).order(display_priority: :asc) 
  end

  def edit
    @contest = @lineup.entries[0].contest
    @positions = SportPosition.where(sport: @lineup.sport, visible: true).includes(:players).order(display_priority: :asc) 
  end

  def result

  end

  def create
    @lineup         = current_user.lineups.create(lineup_parameters)

    # Create an entry that new lineup belongs to
    @entry = Contest.find(@lineup.contest_id_to_enter).enter(@lineup) if @lineup.contest_id_to_enter.present?

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
    @lineups = current_user.lineups.includes([:lineup_spots]).order(updated_at: :desc).limit 3
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
  def set_lineup
    @lineup = Lineup.find(params[:id])
  end

  def lineup_parameters
    params.require(:lineup).permit(:contest_id_to_enter, :sport, lineup_spots_attributes: [:player_id, :id, :sport_position_id, :spot])
  end
end
