class RealTimeDataService
  REALTIME_STATS = [ 
      "points",
      "assists",
      "steals",
      "rebounds",
      "blocks",
      "turnovers"
  ]

  def refresh_schedule(schedule_summary)
    ActiveRecord::Base.logger = Logger.new(STDOUT)

    schedule_summary.select do |game_summary|
      # one game received from the external API. Check if we need to update our local Game data, and
      # if we need to get realtime play info.

      # find or create the teams and game model entries for this game.
      (home_team, away_team) = ['home', 'away'].map do |home_or_away|
        home_team = Team.where(ext_team_id: game_summary["#{home_or_away}_team"]).first_or_create do |team|
          team.name = game_summary[home_or_away]['name']
          team.teamalias = game_summary[home_or_away]['alias']
        end
      end

      game_score = GameScore.where(ext_game_id: game_summary['id']).first_or_create do |game|
        game.status = game_summary['status']
        game.playdate = game_summary['scheduled'].in_time_zone('EST')
        game.scheduledstart = game_summary['scheduled']
        game.home_team = home_team
        game.away_team = away_team
      end

      # skip the game if the game hasn't started.
      !(game_score.in_future? || game_score.closed?)
    end
  end

  def refresh_game(game_src)
    game_score = GameScore.where(ext_game_id: game_src['id']).first
    unless game_score
      Rails.logger.warn("GameScore not found for #{game_src['id']}")
      return
    end
    game_score.record_sportsdata(game_src)

    cal = Projection::FantasyPointCalculator.new
    changed_scores = []

    return unless game_src['team']

    # iterate through each of the players in both teams of the game, updating their realtime stats.
    game_src['team'].map {|t| t['players']['player'] }.flatten.each do |player_src|

      Player.player_of_ext_id player_src["id"] do |player|
        changed = false
        stats = player_src["statistics"]
        stats.each do |name, value|
          next unless REALTIME_STATS.include? name
          score = PlayerRealTimeScore.where(player: player, name: name,
                                            game_score:game_score).first_or_initialize
          if score.value != value.to_f
            score.value = value.to_f
            score.save!
            changed_scores << score
            changed = true
          end
        end # of player_src["statistics"].each do |name, value|

        # add "fp" stat if anything changed
        if changed
          score = PlayerRealTimeScore.where(player: player, name: "fp",
                                            game_score:game_score).first_or_initialize
          score.value = cal.weighted_fp { |stat_name, weight| stats[stat_name].to_f }
          score.save!
          changed_scores << score
        end

      end # of Player.player_of_ext_id player_src["id"] do |player|

    end # of all player loop

    # Recompute each Entry's current fantasypoints for sending to front end.
    # Multiple messages sent to stay within Pusher limits.
    if changed_scores.size > 0
      # send this game's updated score to the browser if anything has changed. Do this first
      # since in the browser, player computation depends on the game scores.
      # Note we send a single-entry araray of "games" to be consistent with the API for entries and
      # players. That way we can change the implementation here to send multiple scores at once if
      # we want to.
      game_score_to_push = {"games" =>  [{"id" => game_score.id,
                                        "playstate" => game_score.pretty_play_state,
                                        "min_remaining" => game_score.minutes_remaining,
                                        "home_team" => {
                                            "score" => game_score.home_team_score,
                                            "alias" => game_score.home_team.teamalias
                                        } ,
                                        "away_team" => {
                                            "score" => game_score.away_team_score,
                                            "alias" => game_score.away_team.teamalias
                                        }} ]
                          }
      Pusher['gamecenter'].trigger('stats', game_score_to_push)

      msg = changed_scores.map {|score| { "id" => score.player_id, "stat_name" => score.name,
                                          "stat_value" => score.value.to_f }}
      #Limit the size of each message (pusher's limit is 10240)
      msg.each_slice(50).each do |msg_chunk|
        Pusher['gamecenter'].trigger('stats', { "players" => msg_chunk })
      end

      # Recalculate all live entries' fantasy points and send as a message.
      @entries = Entry.live.map {|entry| {"id" => entry.id, "fps" => entry.current_fantasypoints}}
      Pusher['gamecenter'].trigger('stats', { "entries" => @entries })

    end
  end
end

