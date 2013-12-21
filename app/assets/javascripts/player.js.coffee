class Player
  id: ''
  name: ''
  salary: 0
  opp: ''
  fppg: ''
  position: ''

  constructor: (dom) ->
    @id       = dom.data('player-id')
    @name     = dom.data('player-name')
    @salary   = dom.data('player-salary')
    @opp      = dom.data('player-opp')
    @fppg     = dom.data('player-fppg')
    @position = dom.data('player-position')

$ ->
  window.Player = Player




