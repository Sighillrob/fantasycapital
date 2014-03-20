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
    # update the GameScore models with game schedules and state. This happens for several days ahead
    # during overnight tasks, and regularly (every 15 seconds) during gametimes.

    # return the list of games that are currently live.
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

      game = GameScore.where(ext_game_id: game_summary['id']).first_or_initialize
      game.status = game_summary['status']
      game.playdate = game_summary['scheduled'].in_time_zone('EST')
      game.scheduledstart = game_summary['scheduled']
      game.home_team = home_team
      game.away_team = away_team
      game.save!

      # send this game's updated score to the browser if anything has changed. Do this first
      # since in the browser, player computation depends on the game scores.
      # Note we send a single-entry araray of "games" to be consistent with the API for entries and
      # players. That way we can change the implementation here to send multiple scores at once if
      # we want to.
      if game.changed?
        # NOTE: I'm sure this can now be simplified -- all the keys and values match
        game_score_to_push = {:games =>  [{"id" => game.id,
                                            "pretty_playstate" => game.pretty_play_state,
                                            "minutes_remaining" => game.minutes_remaining,
                                            "home_team_score" => game.home_team_score,
                                            "away_team_score" => game.away_team_score
                                            } ]
        }
        Pusher['gamecenter'].trigger('stats', game_score_to_push)
      end

      # skip the game if the game hasn't started or is over. we're in a select, so a TRUE means return this
      #  schedule item.
      !game.in_future? && !game.closed?
    end
  end

  def refresh_game(game_src)
    game_score = GameScore.where(ext_game_id: game_src['id']).first

    unless game_score
      Rails.logger.warn("GameScore not found for #{game_src['id']}")
      return
    end
    if game_score.record_sportsdata(game_src)
      game = game_score
      # NOTE: I'm sure this can now be simplified -- all the keys and values match
      game_score_to_push = {:games =>  [{"id" => game.id,
                                          "pretty_play_state" => game.pretty_play_state,
                                          "minutes_remaining" => game.minutes_remaining,
                                          "home_team_score" => game.home_team_score,
                                          "away_team_score" => game.away_team_score,
                                         } ]
      }
      Pusher['gamecenter'].trigger('stats', game_score_to_push)

    end

    cal = Projection::FantasyPointCalculator.new

    teams_src = game_src['team'] || []

    changed_players = [].to_set
    # iterate through each of the players in both teams of the game, updating their realtime stats.
    teams_src.map {|t| t['players']['player'] }.flatten.each do |player_src|
      player = Player.where(ext_player_id: player_src['id']).first_or_create

      changed = false

      stats = player_src["statistics"] || []
      stats.each do |name, value|
        next unless REALTIME_STATS.include? name
        score = PlayerRealTimeScore.where(player: player, name: name,
                                          game_score:game_score).first_or_initialize
        if score.value != value.to_f
          score.value = value.to_f
          score.save!
          changed = true
        end
      end # of player_src["statistics"].each do |name, value|

      # add "fp" stat if anything changed
      if changed
        score = PlayerRealTimeScore.where(player: player, name: "fp",
                                          game_score:game_score).first_or_initialize
        score.value = cal.weighted_fp { |stat_name, weight| stats[stat_name].to_f }
        score.save!
        changed_players.add(player)
      end


    end # of all player loop

    # update each player's fantasy points.
    playerstats = changed_players.map {|player|
      pl_json = {id: player.id}
      pl_json[:rtstats] = player.rtstats(game_score.id)
      pl_json[:currfps] = player.realtime_fantasy_points(game_score.id).to_i
      pl_json
    }


    ##Limit the size of each message (pusher's limit is 10240)
    playerstats.each_slice(50).each do |msg_chunk|
      Pusher['gamecenter'].trigger('stats', { :players => msg_chunk })
    end

    if changed_players
      # Recalculate all live entries' fantasy points and send as a message. Need a list of all game IDs
      # today since the entry will span multiple games.
      @entries = Entry.live.map {|entry| {"id" => entry.id, "fps" => entry.current_fantasypoints}}
      if !@entries.empty?
        Pusher['gamecenter'].trigger('stats', { :entries => @entries })
      end

    end
  end
end

