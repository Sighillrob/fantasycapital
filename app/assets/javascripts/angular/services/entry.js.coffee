fantasysport = angular.module("fantasysport")

fantasysport.factory "searchEntries", ["$resource", ($resource) ->
	$resource "/api/searchEntries"
]

