class Main.Models.Player extends Backbone.Model
  debug: false
  defaults:
    0
  initialize: () ->
    if @debug
      console.log("initializing a player")
      @name()

  name: () ->
    if @debug
      console.log("invoking name -> name: " + @get("first_name") + " " + @get("last_name"));
    @get("first_name") + " " + @get("last_name")

  team: () ->
    if @debug
      console.log("invoking team -> team_id: " + @get("team_id"));
    @collection.teams_coll.get(@get('team_id'))

  sportposition: () ->
    @collection.sportpositions_coll.get(@get('sport_position_id'))

  currgame: () ->
    # out of the games on this JS page, return the one he's playing in.
    team = @team()
    gamedate = @collection.contest.get('contestdate')
    games = []
    if team
      games = @collection.games_coll.where({away_team_id: team.id, playdate:gamedate}).concat(
              @collection.games_coll.where({home_team_id: team.id, playdate:gamedate}))
    if games.length > 1
      console.log("Player in multiple games?")
      console.log(games)
      return null
    if games.length == 0
      return null
    return games[0]
  getTeamID: () ->
    return @team().id || null
  getTeam: () ->
    mygame = @currgame()
    return "None" if !mygame
    return mygame.get_team_alias(@getTeamID())
  scorestring: () ->
    mygame = @currgame()
    return "None" if !mygame
    return mygame.score_string()
  teamsstring: () ->
    mygame = @currgame()
    return "None" if !mygame
    return mygame.home_team_alias() + "@" + mygame.away_team_alias()
  getHomeTeam: () ->
    mygame = @currgame()
    return "None" if !mygame
    return mygame.home_team_alias()
  getAwayTeam: () ->
    mygame = @currgame()
    return "None" if !mygame
    return mygame.away_team_alias()
  salarystring: () ->
    accounting.formatMoney(@get('salary'), {precision: 0});



class Main.Collections.PlayersCollection extends Backbone.Collection
  model: Main.Models.Player

  initialize: (models, args) ->
    @teams_coll = args.teams_coll
    @games_coll = args.games_coll
    @sportpositions_coll = args.sportpositions_coll
    @contest = args.contest



