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
    teams_coll.get(@get('team_id'))

  currgame: () ->
    # out of the games on this JS page, return the one he's playing in.
    team = @team()
    gamedate = contest.get('contestdate')
    games = []
    if team
      games = games_coll.where({away_team_id: team.id, playdate:gamedate}).concat(
              games_coll.where({home_team_id: team.id, playdate:gamedate}))
    if games.length > 1
      console.log("Player in multiple games?")
      console.log(games)
      return null
    if games.length == 0
      return null
    return games[0]

  scorestring: () ->
    mygame = @currgame()
    return "None" if !mygame
    return mygame.score_string()

class Main.Collections.PlayersCollection extends Backbone.Collection
  model: Main.Models.Player
