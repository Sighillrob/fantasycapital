class EntriesController < ApplicationController
  #before_action :set_contest, only: [:new, :create]

  def new
    #@positions = @contest.sport_positions.includes(:players).order(display_priority: :asc)
    #@entry     = Entry.build_entry_for_contest @contest
  end

  def edit
  end

  def show
  end

  # POST /entries
  # POST /entries.json
  def create
    # @entry = Entry.create(entry_parameters)

    #respond_to do |format|
    # if @entry.save
    #   format.html { redirect_to [@contest, @entry], notice: 'Entry was successfully created.' }
    #   format.json { render action: 'show', status: :created, location: @entry }
    # else
    #   format.html { render action: 'new' }
    ##   format.json { render json: @entry.errors, status: :unprocessable_entity }
    # end
  end

#private
#def set_contest
# @contest = Contest.find(params[:contest_id])
#end

#def entry_parameters
#  params.require(:entry).permit(:contest_id, lineups_attributes: [:sport_position_id, :player_id])
#end

end
