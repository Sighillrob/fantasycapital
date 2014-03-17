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
    # this is the real-time "gamecenter" action. It shows a contest from a particular
    # day.
    @entry_id = params[:id]
    @entry = Entry.find(params[:id])
    @contest = @entry.contest
    @entrysummarys = @entry.contest.entries
    @games = GameScore.recent_and_upcoming  # BUGBUG: do we need this? or just today's games?


    # get all the player scores for today's games
    @todaysgames = GameScore.where({playdate: @contest.contestdate-1})  # BUGBUG: Remove -1 !!!
    todaygameids = @todaysgames.pluck('id')
    @playerscores = PlayerRealTimeScore.where(game_score_id: todaygameids)

    # get player scores from that days' games.
    #@playerscores = PlayerRealTimeScore.joins(:game_score).where(
    #                  game_scores:{playdate: @contest.contestdate-1})
    @teams = Team.all
    @players = Player.all
    @sportpositions = SportPosition.all
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
