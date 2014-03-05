window.GameCenterCtrl = ($scope, $http, Pusher) ->
	$scope.stat_names = ['points', 'assists', 'steals', 'rebounds', 'blocks', 'turnovers']
	$scope.stat_rules = 
		points: 1
		assists: 1.5
		steals: 2
		rebounds: 1.25
		blocks: 2
		turnovers: -1

	$scope.my_total_score = 0
	$scope.gc_init = (entry_id) ->
		$scope.entry_id = entry_id
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
			$scope.my = data.my
			
			$scope.calculate_scores()

		).error (data, status, headers, config) ->
			console.log('error')

	$scope.calculate_scores = ->
		i = 0
		$scope.my_total_score = 0
		while i < $scope.lineup_spots.length
			j = 0
			$scope.lineup_spots[i].score = 0
			while j < $scope.stat_names.length
				$scope.lineup_spots[i].score += $scope.lineup_spots[i].stats[$scope.stat_names[j]] * $scope.stat_rules[$scope.stat_names[j]]
				j++

			$scope.my_total_score += $scope.lineup_spots[i].score
			i++

	Pusher.subscribe "gamecenter", "stats", (data) ->
		i = 0
		console.log(data)
		while i < data.players.length
			j = 0
			while j < $scope.lineup_spots.length
				if data.players[i].id is $scope.lineup_spots[j].player.id
					$scope.lineup_spots[j].stats[data.players[i].stat_name] = data.players[i].stat_value
				j++
			i++
		$scope.calculate_scores()

