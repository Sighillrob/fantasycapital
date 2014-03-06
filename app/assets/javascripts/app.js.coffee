window.App = angular.module('fantasysport', ['ngResource'])

$(document).on 'page:load', ->
 	$('[ng-app]').each ->
    	module = $(this).attr('ng-app')
    	angular.bootstrap(this, [module])
