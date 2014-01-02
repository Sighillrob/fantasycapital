$ ->
  $("a[rel=popover]").popover()
  $(".tooltip").tooltip()
  $("[rel=tooltip]").tooltip({html: true})
  $('.tabs a:first').tab('show');