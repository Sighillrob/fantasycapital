class EntriesController < ApplicationController
  before_action :set_contest, only: [:new, :create]

  def new
    @positions = @contest.sport_positions.order(display_priority: :asc)
  end

  def edit
  end

  def show
  end

  # POST /entries
  # POST /entries.json
  def create
    @entry = Entry.new(contest: @contest)
    params[:player_ids].each do |player_id|
      @entry.lineups.build(player_id: player_id)
    end

    respond_to do |format|
      if @entry.save
        format.html { redirect_to [@contest, @entry], notice: 'Entry was successfully created.' }
        format.json { render action: 'show', status: :created, location: @entry }
      else
        format.html { render action: 'new' }
        format.json { render json: @entry.errors, status: :unprocessable_entity }
      end
    end
  end

  private
  def set_contest
    @contest = Contest.find(params[:contest_id])
  end

end
