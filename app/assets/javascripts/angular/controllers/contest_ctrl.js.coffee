window.ContestCtrl = ($scope, searchEntries) ->
	$scope.search = ->
		searchEntries.get((data) ->
			$scope.liveContests = data.liveContests
			$scope.upcomingContests = data.upcomingContests
			$scope.completedContests = data.completedContests
		)
