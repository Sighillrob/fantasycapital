class Main.Models.Game extends Backbone.Model
  paramRoot: 'game'

  defaults:
    name: 'Foo'
    id: 0

  initialize: () ->
    console.log "HI"

  min_left: () ->
    console.log "UNIMPLEMENTED MIN.LEFT IN BackBone Game model"
    return 2

  home_team_alias: () ->
    teams_coll.get(@get('home_team_id')).get('teamalias')

  away_team_alias: () ->
    teams_coll.get(@get('away_team_id')).get('teamalias')

  score_string: () ->
    if @get('status') == 'scheduled'
      return @away_team_alias() + " @ " + @home_team_alias()
    @away_team_alias() + " " + @get('away_team_score') + " @ " +
    @home_team_alias() + " " + @get('home_team_score') + " " #+ @get('playstate')


class Main.Collections.GamesCollection extends Backbone.Collection
  model: Main.Models.Game
  url: '/games'