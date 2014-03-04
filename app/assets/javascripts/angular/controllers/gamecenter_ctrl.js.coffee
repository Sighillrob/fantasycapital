window.GameCenterCtrl = ($scope, $http, Pusher) ->
	$scope.my_total_score = 0
	$scope.gc_init = (entry_id) ->
		$scope.entry_id = entry_id
		console.log(entry_id)
		$http(
  			method: "GET"
  			url: "/api/gc_data/" + entry_id
		).success((data, status, headers, config) ->
			console.log(data)
			$scope.entry = data.entry
			$scope.contest = data.contest
			$scope.users = data.users
			$scope.lineup = data.lineup
			$scope.lineup_spots = data.lineup_spots
			i = 0
			while i < $scope.lineup_spots.length
				$scope.my_total_store += $scope.lineup_spots[i].score
				i++

		).error (data, status, headers, config) ->
			console.log('error')

	Pusher.subscribe "gamecenter", "stats", (data) ->
		i = 0
		while i < data.players.length
			j = 0
			while j < $scope.lineup_spots.length
				if data.players[i].player is $scope.lineup_spots[j].player.id
					$scope.lineup_spots[j].score =  $scope.lineup_spots[j].score + data.players[i].stat_value - $scope.lineup_spots[j].stats[data.player[i].stat_name]
					$scope.my_total_score =  $scope.my_total_score + data.players[i].stat_value - $scope.lineup_spots[j].stats[data.player[i].stat_name]
					$scope.lineup_spots[j].stats[data.player[i].stat_name] = data.players[i].stat_value
				j++
			i++