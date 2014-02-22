fantasysport = angular.module("fantasysport")

fantasysport.directive "timeCounting", ($parse, $compile, $interpolate) ->
  link: (scope, el, attrs) ->
  	$(el).countdown
      date: $interpolate($(el).html())(scope)
      render: (date) ->
      	min = if date.min > 9 then date.min else '0' + date.min.toString()
      	sec = if date.sec > 9 then date.sec else '0' + date.sec.toString()
      	days = date.days
      	$(el).html date.days*24 + date.hours + ":" + min + ":" + sec
       
      onEnd: ->
        scope.search()
