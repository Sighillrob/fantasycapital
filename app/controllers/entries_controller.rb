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
    @entries = @entry.contest.entries

    @games = GameScore.recent_and_upcoming  # BUGBUG: do we need this? or just today's games?

    # get all the player scores for today's games
    @todaysgames = GameScore.where({playdate: @contest.contestdate})

    @teams = Team.all

    # add today's scores to the players in a consumable format.
    todaygameids = @todaysgames.pluck('id')

    # BUGBUG: change this to players that are in this contest...
    @rawplayers = Player.all.to_a
    @players = @rawplayers.map { |player|
      pl_json = player.as_json()
      pl_json['rtstats'] = player.rtstats(todaygameids)
      pl_json['currfps'] = player.realtime_fantasy_points(todaygameids)
      pl_json
    }
    @sportpositions = SportPosition.all
  end

  def index
    # seeding the data object
    todaydate = Time.now.in_time_zone("US/Pacific").to_date

    liveContests = []
    upcomingContests = []
    completedContests = []

    entries_in_play = current_user.entries.in_range(todaydate-7, todaydate+7).
                        includes(:contest).includes(:lineup)

    entries_in_play.each do |entry|
      # the API has a funky format, close to a contest but not quite. Build up an element for it.
      contest = entry.contest.attributes
      contest['results_path'] = entry_path(entry)
      contest['view_path'] = entry_path(entry)
      contest['edit_path'] = edit_lineup_path(entry.lineup)

      # determine which list the entry goes on.
      state = entry.contest.accurate_state
      completedContests << contest if state == :closed
      liveContests << contest if state == :live
      upcomingContests << contest if state == :in_future
    end

    # the completed contests array does not hold any information
    # about the final ranking of the contestant
    # could you please provide a final_ranking key
    # to each object in the completed contests array?
    # the template is already prepared for this key

    @data = {
      liveContests: liveContests, 
      upcomingContests: upcomingContests,
      completedContests: completedContests
    }

    
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
