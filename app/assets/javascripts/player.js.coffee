class Player
  id: ''
  name: ''
  salary: 0
  opp: ''
  fppg: ''
  position: ''

  constructor: (dom) ->
    if dom?
      @id       = dom.data('player-id')
      @name     = dom.data('player-name')
      @salary   = dom.data('player-salary')
      @opp      = dom.data('player-opp')
      @fppg     = dom.data('player-fppg')
      @position = dom.data('player-position')

  bindAll: ->
    $(".player-stats").on 'click', ->
      new window.AjaxModal($(@).data('stats-url')).load()

$ ->
  window.Player = Player
  (new Player()).bindAll()



