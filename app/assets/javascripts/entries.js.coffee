# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
class Lineup
  salary_cap: 0
  entries:    []

  constructor: ->
    @fixHeight()
    that        = @
    @salary_cap = $('#contest-salary-sap').data('salary')
    $(".lineup-spot").each (i, obj) ->
      that.entries.push(new Entry($(@)))

    $('a#clear-lineups').on 'click', ->
      if confirm("Are you sure to clear your lineup?")
        that.clear()

    $('a.add-to-lineup').on 'click', ->
      player = new window.Player($(@).closest('tr.contest-player'))
      if that.canAddPlayer(player)
        eligible_spots = (spot for spot in that.entries when (spot.position is player.position or spot.position is 'UTIL') and not spot.player)
        if eligible_spots.length is 0
          alert "Please remove player from position "+player.position
        else
          eligible_spots[0].player = player
          $("tr[data-player-id='"+player.id+"']").hide()
        that.updateView()
      else
        alert "You can't add this player. Salary limit reached!"

    $('a.remove-from-lineup').on 'click', ->
      spot_seq = $(@).data('lineup-spot')
      spots = (spot for spot in that.entries when spot.spot is spot_seq and not not spot.player)
      for spot in spots
        $("tr[data-player-id='"+spot.player.id+"']").show()
        spot.player = ''
      that.updateView()

  consumedSalary: ->
    alloted_spots = (spot for spot in @entries when not not spot.player)
    alloted_spots.map((entry) ->
      entry.player.salary
    ).reduce (a, b) ->
      a + b
    , 0

  canAddPlayer: (player) ->
    @consumedSalary() + player.salary < @salary_cap

  clear: ->
    @entries = []
    @updateView()

  updateView: ->
    $('tr.entry-item').find('td.val span').html '&nbsp;'
    $('#contest-salary-cap').html (@salary_cap - @consumedSalary())
    $('#contest-salary-consumed').html @consumedSalary()
    $('.currency').currency
      region: 'USD'
      thousands: ','
      decimal: '.'
      decimals: 0
      hidePrefix: false

    $.each @entries, (i, entry) ->
      entry.render()

  fixHeight: ->
    minHeight = $('div.capitalcontent').find('.same-height:first').height()
    $('div.capitalcontent').find('.same-height').each ->
      minHeight= Math.min minHeight, $(this).height()
    $('.same-height').css({height: minHeight+'px'})

class Entry
  player: ''
  position: ''
  spot: ''

  constructor: (dom) ->
    @position = dom.data('sport-position-name')
    @spot = dom.data('spot')

  render: ->
    dom = $("tr.lineup-spot[data-spot="+@spot+"]")
    dom.find('td.player input').val @player.id
    dom.find('td.player span').html @player.name || "&nbsp;"
    dom.find('td.opp span').html @player.opp || "&nbsp;"
    dom.find('td.salary span').html @player.salary || "&nbsp;"
    dom.find('td.fppg span').html @player.fppg || "&nbsp;"

$ ->
  new Lineup
