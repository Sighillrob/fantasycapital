$ ->
  $("a[rel=popover]").popover()
  $(".tooltip").tooltip()
  $("[rel=tooltip]").tooltip({html: true})
  $('.tabs a:first').tab('show')
  $("html").on 'click', '.ajax-modal', ->
    new window.AjaxModal($(@).data('url')).load()

  $('[data-time]').localDate()
  $('.countdown').timeRemaining()


