window.App = angular.module('fantasysport', ['ngResource'])

$(document).on('ready page:load', ->
  if $(".ng-bootstrap-angular").length
    angular.bootstrap($(".ng-bootstrap-angular")[0], ['fantasysport'])
)

