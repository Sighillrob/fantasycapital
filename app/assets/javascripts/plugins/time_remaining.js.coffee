$.fn.timeRemaining = ->
  @each ->
    el = $(@)
    date = el.data('date')

    # Show local tooltip
    el.attr 'title', $.localDate(date)
    el.tooltip()

    # Call the countdown plugin
    el.countdown
      date: date
      render: (date) ->
        el.html(date.hours+":"+date.min+":"+date.sec)
      onEnd: ->
        el.addClass('ended')
        el.html($(@).data('finished-message'))

