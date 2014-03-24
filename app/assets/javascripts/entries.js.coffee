class Lineup
  salary_cap: 0
  entries:    []

  constructor: (salary_param, entries_param) ->
    ###
    @fixHeight()
    ###
    that        = @
    @salary_cap = $('#contest-salary-cap').data('salary') || salary_param
    @entries = entries_param || []
    $(".lineup-spot").each (i, obj) ->
      that.entries.push(new Entry($(@)))

    $('a#clear-lineups').on 'click', ->
      if confirm("Are you sure to clear your lineup?")
        that.clear()

    $('a.add-to-lineup').on 'click', ->
      # add player to lineup if eligible, and remove from DOM. 'that' is the constructed lineup.
      player = new window.PlayerStats($(@).closest('tr.contest-player'))
      if that.canAddPlayer(player)
        eligible_spots = (spot for spot in that.entries when (spot.position is player.position or spot.position is 'UTIL') and not spot.player)
        if eligible_spots.length is 0
          alert "Please remove player from position "+player.position
        else
          eligible_spots[0].player = player
          # this is really a backbone view, but for now we just mess with it in HTML. Ultimately
          # we should transition this Lineup logic into backbone.
          $('tr[data-player-id="'+player.id+'"]').hide()
        that.updateView()
      else
        alert "You can't add this player. Salary limit reached!"

    $('a.remove-from-lineup').on 'click', ->
      spot_seq = $(@).data('lineup-spot')
      spots = (spot for spot in that.entries when spot.spot is spot_seq and not not spot.player)
      for spot in spots
        $('tr[data-player-id="'+spot.player.id+'"]').show()
        spot.player = ''
      that.updateView()
    @updateView()

    $('#new_lineup').submit (event) ->
      spots = (spot for spot in that.entries when not spot.player)
      if spots.length is 0
        return true
      alert "Team needs to be completely filled before it can be submitted."
      return false
  setSalaryCap: (value) ->
    if typeof value == "number"
      if value > 0
        @salary_cap = value
      else
        @salary_cap = 0
    else
      @salary_cap = 0  
  addEntry: (el) ->
    if el instanceof Entry
      @entries.push(el)
    else
      @entries.push(new Entry($(el)))
  getNumberOfEntries: ->
    @entries.length
  getAllEntries: ->
    @entries
  clearEntries: ->
    @entries = []
  getAllSalaries: ->
    alloted_spots = (spot for spot in @entries when not not spot.player)
    alloted_spots.map((entry) ->
      entry.player.salary
    )
  getMinPlayerSalary: ->
    Math.min.apply(Math, @getAllSalaries())
  getMaxPlayerSalary: ->
    Math.max.apply(Math, @getAllSalaries())
  getSalaryCap: ->
    @salary_cap
  consumedSalary: ->
    @getAllSalaries().reduce (a, b) ->
      a + b
    , 0
  amountLeft: ->
    @salary_cap - @consumedSalary()
  canAddPlayer: (player) ->
    @consumedSalary() + player.salary <= @salary_cap
  spotsTaken: ->
    (spot for spot in @entries when not not spot.player).length
  spotsLeft: ->
    (spot for spot in @entries when not spot.player).length
  averagePlayerSalary: ->
    (@consumedSalary()/@spotsTaken()) || 0
  averageRemainingPlayerSalary: ->
    @amountLeft()/@spotsLeft()
  sortBy: (field, order) ->
    if @getNumberOfEntries() > 0
      if order == "desc"
        order = -1
      else
        order = 1
      @entries = @entries.sort (a, b) ->
        if a.player[field] < b.player[field] 
          return (-1 * order);
        if a.player[field] > b.player[field] 
          return (1 * order);
        return 0;
      return @entries
    else
      return []
  sortBySalary: (order) ->
    @sortBy("salary", order)

  sortByName: (order) ->
    @sortBy("name", order)
  clear: ->
    @entries.map (entry) ->
      entry.player = ''
    @updateView()
  updateView: ->
    $('tr.entry-item').find('td.val span').html '&nbsp;'
    $('#contest-salary-cap').html (@amountLeft())
    $('#avg-rem-salary').html (@averageRemainingPlayerSalary()).toFixed(2)

    $.each @entries, (i, entry) ->
      entry.render()

    $('.currency').currency
      region: 'USD'
      thousands: ','
      decimal: '.'
      decimals: 0
      hidePrefix: false

  fixHeight: ->
    minHeight = $('div.capitalcontent').find('.same-height:first').height()
    $('div.capitalcontent').find('.same-height').each ->
      minHeight= Math.min minHeight, $(this).height()
    $('.same-height').css({height: minHeight+'px'})

class Entry
  player: ""
  position: ""
  spot: ""

  constructor: (dom) ->
    @position = dom.data('sport-position-name') || ""
    @spot     = dom.data('spot') || ""
    @player   = ""
    player_id = dom.data('player-id') || ""

    if player_id?
      player_dom = $('tr.contest-player#player_'+player_id)
      # BUGBUG: this isn't currently exercised... add the following selector below. But is this still needed?
      # $('tr[data-player-id="'+player.id+'"]')
      if player_dom.length
        @player = new window.PlayerStats(player_dom)
        player_dom.hide()
    @spot = dom.data('spot')

  addPlayer: (player) ->
    if player instanceof PlayerStats
      @.player = player
    else
      return null
  getPlayer: ->
    @.player
  removePlayer: ->
    @.player = ""
  playerExists: ->
    @.player != ""
  render: ->
    that = @

    dom = $("tr.lineup-spot[data-spot="+ @spot+"]")
    dom.find('td.player input').attr("value", that.player.id) 
    dom.find('td.player span').html @player.name || "&nbsp;"
    dom.find('td.opp span').html @player.opp || "&nbsp;"
    dom.find('td.salary span').html @player.salary || "&nbsp;"
    dom.find('td.fppg span').html @player.fppg || "&nbsp;"

$(document).on "ready page:load": ->
  window.Lineup = Lineup
  window.Entry = Entry
