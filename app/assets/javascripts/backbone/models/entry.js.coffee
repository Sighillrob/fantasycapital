class Main.Models.Entry extends Backbone.Model
  paramRoot: 'entry'
  urlRoot: '/api/gc_data2/'
  defaults:
    name: 'Foo'
    id: 0
    lineup_spots: []
    player_ids: []

  initialize: () ->
    0

  players: () ->
    # return player model instances for this Entry
    _.map( @get('player_ids'),  (playerid) -> players_coll.get(playerid) )

  min_left: () ->
    entry_min_left = 0
    players = @players()
    if players
      $.each(players, (index, player) ->
        game = player.currgame()
        entry_min_left += game.get('minutes_remaining')
      )
    return entry_min_left

class Main.Collections.EntriesCollection extends Backbone.Collection
  model: Main.Models.Entry
  url: '/entries'
