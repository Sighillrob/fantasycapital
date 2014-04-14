class Main.Models.Game extends Backbone.Model
  paramRoot: 'game'

  defaults:
    id: 0

  initialize: () ->
    0

  get_team_alias: (id) ->
    if @collection && @collection.teams_coll
      return @collection.teams_coll.get(id).get('teamalias')
    return null
  home_team_alias: () ->
    @get_team_alias(@get('home_team_id'))
  away_team_alias: () ->
    @get_team_alias(@get('away_team_id'))
  score_string: () ->
    if @get('status') == 'scheduled'
      return @away_team_alias() + " @ " + @home_team_alias()
    @away_team_alias() + " " + @get('away_team_score') + " @ " +
    @home_team_alias() + " " + @get('home_team_score') + " " #+ @get('playstate')

  teams_string: () ->
    if @collection && @collection.teams_coll
      return @home_team_alias() + "@" + @away_team_alias()
    return ""
  teams_string_and_date: () ->
    if @collection && @collection.teams_coll
      if moment().isDST()
        start = moment.utc(@get("scheduledstart")).subtract("hours", 4).format("hh:mma") + " EDT"
      else
        start = moment.utc(@get("scheduledstart")).subtract("hours", 5).format("hh:mma") + " EST"
      return @home_team_alias() + "@" + @away_team_alias() + " " + start
    return ""

class Main.Collections.GamesCollection extends Backbone.Collection
  model: Main.Models.Game
  url: '/games'
  comparator: (model) ->
    # ensure that the order is correct
    moment(model.get("scheduledstart")).unix()
  initialize: (models, args) ->
    @teams_coll = args.teams_coll