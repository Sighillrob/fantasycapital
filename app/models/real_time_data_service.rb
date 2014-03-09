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
    cal = Projection::FantasyPointCalculator.new
    changed_scores = []
    
    game_src.map {|t| t['players']['player'] }.flatten.each do |player_src|

      Player.player_of_ext_id player_src["id"] do |player|
        changed = false
        stats = player_src["statistics"]
        stats.each do |name, value|
          next unless REALTIME_STATS.include? name
          score = PlayerRealTimeScore.where(player: player, name: name).first_or_initialize
          if score.value != value.to_f
            score.value = value.to_f
            score.save!
            changed_scores << score
            changed = true
          end
        end # of player_src["statistics"].each do |name, value|

        # add "fp" stat if anything changed
        if changed
          score = PlayerRealTimeScore.where(player: player, name: "fp").first_or_initialize
          score.value = cal.weighted_fp { |stat_name, weight| stats[stat_name].to_f }
          score.save!
          changed_scores << score
        end

      end # of Player.player_of_ext_id player_src["id"] do |player|

    end # of all player loop

    #trigger event to frontend
    if changed_scores.size > 0
      msg = changed_scores.map {|score| { "id" => score.player_id, "stat_name" => score.name, "stat_value" => score.value.to_f }}
      #Limit the size of each message (pusher's limit is 10240)
      msg.each_slice(50).each do |msg_chunk|
        Pusher['gamecenter'].trigger('stats', { "players" => msg_chunk })
      end
    end
  end
end
