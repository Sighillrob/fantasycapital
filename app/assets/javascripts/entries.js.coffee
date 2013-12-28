# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
class Lineup
  salary_cap: 0
  entries:    []

  constructor: ->
    that        = @
    @salary_cap = $('#contest-salary-sap').data('salary')

    $('a#clear-lineups').on 'click', ->
      that.clear()

    $('a.add-to-lineup').on 'click', ->
      player = new window.Player($(@).closest('tr.contest-player'))
      if that.canAddPlayer(player)
        i = 0
        while i < that.entries.length
          if that.entries[i].position is player.position
            prev_entry = that.entries.splice(i, 1)[0]
            $("tr[data-player-id='"+prev_entry.player.id+"']").show()
          i++
        that.entries.push(new Entry(player))
        that.updateView()
        $("tr[data-player-id='"+player.id+"']").hide()
      else
        alert "You can't add this player. Salary limit reached!"

    $('a.remove-from-lineup').on 'click', ->
      position = $(@).data('position')
      i = 0
      while i < that.entries.length
        if that.entries[i].position is position
          prev_entry = that.entries.splice(i, 1)[0]
          $("tr[data-player-id='"+prev_entry.player.id+"']").show()
        i++
      that.updateView()

  consumedSalary: ->
    @entries.map((entry) ->
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
    $('#contest-salary-sap').html '$'+(@salary_cap - @consumedSalary())
    $('#contest-salary-consumed').html '$'+@consumedSalary()

    $.each @entries, (i, entry) ->
      entry.render()

class Entry
  player: ''
  position: ''

  constructor: (player) ->
    @player   = player
    @position = player.position

  render: ->
    dom = $("tr#entry_"+@player.position)
    dom.find('td.player input').val @player.id
    dom.find('td.player span').html @player.name
    dom.find('td.opp span').html @player.opp
    dom.find('td.salary span').html @player.salary
    dom.find('td.fppg span').html @player.fppg

$ ->
  new Lineup
