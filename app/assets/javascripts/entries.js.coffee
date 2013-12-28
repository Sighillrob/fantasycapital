# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
class Lineup
  player: ''
  position: ''

  constructor: (player) ->
    @player   = player
    @position = player.position

  render: ->
    dom = $("tr#lineup_"+@player.position)
    dom.find('td.player input').val @player.id
    dom.find('td.player').html @player.name
    dom.find('td.opp').html @player.opp
    dom.find('td.salary').html @player.salary
    dom.find('td.fppg').html @player.fppg

class Entry
  lineups: []

  constructor: ->
    that = @
    $('a#clear-lineups').on 'click', ->
      that.clear()

    $('a.add-to-lineup').on 'click', ->
      player = new window.Player($(@).closest('tr.contest-player'))
      i = 0
      while i < that.lineups.length
        if that.lineups[i].position is player.position
          prev_lineup = that.lineups.splice(i, 1)[0]
          $("tr[data-player-id='"+prev_lineup.player.id+"']").show()
        i++
      that.lineups.push(new Lineup(player))
      that.updateView()
      $("tr[data-player-id='"+player.id+"']").hide()

    $('a.remove-from-lineup').on 'click', ->
      position = $(@).data('position')
      i = 0
      while i < that.lineups.length
        if that.lineups[i].position is position
          prev_lineup = that.lineups.splice(i, 1)[0]
          $("tr[data-player-id='"+prev_lineup.player.id+"']").show()
        i++
      that.updateView()

  clear: ->
    @lineups = []
    @updateView()

  updateView: ->
    $('tr.lineup-item').find('td.val').empty()
    $.each @lineups, (i, lineup) ->
      lineup.render()


$ ->
  new Entry
