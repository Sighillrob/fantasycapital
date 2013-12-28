class LineupsController < ApplicationController
  before_action :set_contest, only: [:new, :create]

  def new
    @positions = @contest.sport_positions.includes(:players).order(display_priority: :asc)
    @lineup     = Lineup.build_entries_for_contest @contest
  end

  def edit
  end

  def show
  end

  # POST /entries
  # POST /entries.json
  def create
    @lineup = Lineup.create(line_parameters)

    respond_to do |format|
      if @lineup.save
        format.html { redirect_to [@contest, @lineup], notice: 'Lineup was successfully created.' }
        format.json { render action: 'show', status: :created, location: @lineup }
      else
        @positions = @contest.sport_positions.includes(:players).order(display_priority: :asc)
        format.html { render action: 'new' }
        format.json { render json: @entry.errors, status: :unprocessable_entity }
      end
    end
  end

  def index

  end

  private
  def set_contest
    @contest = Contest.find(params[:contest_id])
  end

  def line_parameters
    params.require(:lineup).permit(:contest_id, entries_attributes: [:player_id])
  end
end
