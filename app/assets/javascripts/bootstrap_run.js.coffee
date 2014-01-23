$ ->
  $("a[rel=popover]").popover()
  $(".tooltip").tooltip()
  $("[rel=tooltip]").tooltip({html: true})
  $('.tabs a:first').tab('show');
  $('.ajax-modal').on 'click', ->
    new window.AjaxModal($(@).data('url')).load()

  $.each $('.countdown'), (dom, i) ->
    $(@).countdown
      date: $(@).data("date")
      render: (date) ->
        $(@el).html(date.hours+":"+date.min+":"+date.sec)
      onEnd: ->
        $(@.el).addClass('ended');
        $(@.el).html($(@).data('finished-message'))

        console.info $(@.el).html()