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
        min = if date.min > 9 then date.min else '0' + date.min.toString()
        sec = if date.sec > 9 then date.sec else '0' + date.sec.toString()
        el.html(date.hours+":"+min+":"+sec)
      onEnd: ->
        el.addClass('ended')
        el.html($(@).data('finished-message'))

