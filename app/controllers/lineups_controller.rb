class LineupsController < ApplicationController
  before_filter :authenticate_user!
  before_action :set_lineup, only: [:edit, :update]

  def new
    @contest = Contest.includes(:eligible_players).find(params[:contest_id])
    @lineup  = Lineup.build_for_contest @contest
    @positions = SportPosition.where(sport: @lineup.sport, visible: true).order(display_priority: :asc)

    #for testing...
    #@eligible_players = Player.all 

    @games = GameScore.where({playdate: @contest.contestdate})
    @teams = Team.all
    @players = @contest.eligible_players
    @sportpositions = SportPosition.all

    # my most complex query ever:
    # we need the associated PlayerStat FPPG score marked 'summary' for each player, the one with
    # the highest display-priority.
    # 1. Use a LEFT JOIN so we get players with no stats. (we've seen a few of those)
    # 2. Put conditions in the JOIN (instead of in a where), again so we keep players
    #    without stats.
    # 3. Use a nested query to select only the Player+PlayerStat entry with highest display-priority
    joinclause = "LEFT JOIN player_stats ON player_stats.player_id = players.id " +
                 "AND player_stats.stat_name = 'FPPG' AND player_stats.dimension = 'summary'"

    innerquery = "(SELECT MAX (player_stats.display_priority) from player_stats " +
                 "WHERE player_stats.player_id = players.id)"

    @players = @players.joins(joinclause).
        where('player_stats IS null OR player_stats.display_priority= ' + innerquery)


    # select fields we want to display, making sure FPPG field is added.
    @players = @players.select('players.id', 'sport_position_id', 'salary', 'first_name',
                               'last_name', 'stat_value AS fppg', 'ext_player_id', 'team_id')
  end

  def edit
    @contest = @lineup.entries[0].contest
    @positions = SportPosition.where(sport: @lineup.sport, visible: true).order(display_priority: :asc) 
  end

  def result

  end

  def create
    begin
      @lineup         = current_user.lineups.create(lineup_parameters)
      # Create an entry that new lineup belongs to
      @entry = Contest.find(@lineup.contest_id_to_enter).enter(@lineup) if @lineup.contest_id_to_enter.present?
    rescue RuntimeError => e
      redirect_to "/", notice: e.message
      return
    end

    respond_to do |format|
      if @lineup.save
        format.html { redirect_to entries_path, notice: 'Lineup was successfully created.' }
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
    #@lineup.contest = @contest ## Nils: This causes a bug, maybe it's outdated code?

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

  def export
    render layout: false
  end

  private
  def set_lineup
    @lineup = Lineup.find(params[:id])
  end

  def lineup_parameters
    params.require(:lineup).permit(:contest_id_to_enter, :sport, lineup_spots_attributes: [:player_id, :id, :sport_position_id, :spot])
  end
end
