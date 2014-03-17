class EntriesController < ApplicationController
  before_action :set_lineup, only: [:new, :create]

  def new
    #@positions = @contest.sport_positions.includes(:players).order(display_priority: :asc)
    #@entry     = Entry.build_entry_for_contest @contest
  end

  def edit
  end

  def admin
    # functions that a site admin can do (some might be only pre-launch)
    if params['command'] == "Make Live"
      # adjust this contest's start time to make it live, and execute captured data via resque
      @entry = Entry.find(params[:id])
      Resque.enqueue(GamePlaybackWorker, params[:id])
      render nothing: true

    end
  end

  def show
    # this is the real-time "gamecenter" action.
    @entry_id = params[:id]
    @entry = Entry.find(params[:id])
    @contest = @entry.contest
    @entries = @entry.contest.entries
  end

  def index
    @entries = current_user.entries
  end

  # POST /entries
  # POST /entries.json
  def create
    entry = current_user.entries.build lineup: @lineup
    message = if entry.save
                "Your entry is submitted successfully!"
              else
                entry.errors.full_messages.first
              end
    redirect_to lineups_path, notice: message
    #respond_to do |format|
    # if @entry.save
    #   format.html { redirect_to [@contest, @entry], notice: 'Entry was successfully created.' }
    #   format.json { render action: 'show', status: :created, location: @entry }
    # else
    #   format.html { render action: 'new' }
    ##   format.json { render json: @entry.errors, status: :unprocessable_entity }
    # end
  end

  private
  def set_lineup
    @lineup = Lineup.find(params[:lineup_id])
  end

#def entry_parameters
#  params.require(:entry).permit(:contest_id, lineups_attributes: [:sport_position_id, :player_id])
#end

end
