class RealTimeDataService
  REALTIME_STATS = [ 
      "points",
      "assists",
      "steals",
      "rebounds",
      "blocks",
      "turnovers"
  ]

  def refresh_game(game_src)
    game_src.map {|t| t['players']['player'] }.flatten.each do |player_src|

      Player.player_of_ext_id player_src["id"] do |player|
        player_src["statistics"].each do |name, value|
          next unless REALTIME_STATS.include? name
          score = PlayerRealTimeScore.where(player: player, name: name).first_or_initialize
          score.value = value
          score.save!
        end
      end
    end # of all player loop
  end
end
