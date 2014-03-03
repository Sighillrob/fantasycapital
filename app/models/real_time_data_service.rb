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
    changed_scores = []
    game_src.map {|t| t['players']['player'] }.flatten.each do |player_src|

      Player.player_of_ext_id player_src["id"] do |player|
        player_src["statistics"].each do |name, value|
          next unless REALTIME_STATS.include? name
          score = PlayerRealTimeScore.where(player: player, name: name).first_or_initialize
          if score.value != value 
            score.value = value
            score.save!
            changed_scores << score
          end
        end
      end

    end # of all player loop

    #trigger event to frontend
    if changed_scores.size > 0
      msg = changed_scores.map {|score| { "player" => score.player_id, score.name => score.value }}
      Pusher['gamecenter'].trigger('stats', { "players" => msg }) 
    end
  end
end
