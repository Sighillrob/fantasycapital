class Main.Models.Game extends Backbone.Model
  paramRoot: 'game'

  defaults:
    id: 0

  initialize: () ->
    0

  home_team_alias: () ->
    @collection.teams_coll.get(@get('home_team_id')).get('teamalias')

  away_team_alias: () ->
    @collection.teams_coll.get(@get('away_team_id')).get('teamalias')

  score_string: () ->
    if @get('status') == 'scheduled'
      return @away_team_alias() + " @ " + @home_team_alias()
    @away_team_alias() + " " + @get('away_team_score') + " @ " +
    @home_team_alias() + " " + @get('home_team_score') + " " #+ @get('playstate')

  teams_string: () ->
    @away_team_alias() + "@" + @home_team_alias()


class Main.Collections.GamesCollection extends Backbone.Collection
  model: Main.Models.Game
  url: '/games'
  initialize: (models, args) ->
    @teams_coll = args.teams_coll