$ ->
  $("a[rel=popover]").popover()
  $(".tooltip").tooltip()
  $("[rel=tooltip]").tooltip({html: true})
  $('.tabs a:first').tab('show');
  $('.ajax-modal').on 'click', ->
    new window.AjaxModal($(@).data('url')).load()
  $('.countdown').countdown
    date: $(@).data("date")
    render: (date) ->
      $(@el).html(date.hours+":"+date.min+":"+date.sec)
