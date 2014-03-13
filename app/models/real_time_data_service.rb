class RealTimeDataService
  REALTIME_STATS = [ 
      "points",
      "assists",
      "steals",
      "rebounds",
      "blocks",
      "turnovers"
  ]

  def refresh_game(game_summary)
    # one game received from the external API. Check if we need to update our local Game data, and
    # if we need to get realtime play info.

    ActiveRecord::Base.logger = Logger.new(STDOUT)

    # find or create the teams and game model entries for this game.
    home_team = Team.where(ext_team_id: game_summary['home_team']).first_or_create do |team|
      team.name = game_summary['home']['name']
      team.teamalias = game_summary['home']['alias']
    end
    away_team = Team.where(ext_team_id: game_summary['away_team']).first_or_create do |team|
      team.name = game_summary['away']['name']
      team.teamalias = game_summary['away']['alias']
    end

    game_score = GameScore.where(ext_game_id: game_summary['id']).first_or_create do |game|
      game.status = game_summary['status']
      game.playdate = game_summary['scheduled'].in_time_zone('EST')
      game.scheduledstart = game_summary['scheduled']
      game.home_team = home_team
      game.away_team = away_team
    end

    # nothing to do here if the game hasn't started.
    return if game.in_future?

    unless game_score.closed?
      # game is not already marked done... get realtime stats, update our state, and push to browser.
      game_src = SportsdataClient::Sports::NBA.full_game_stats(game_summary['id']).result['game']

      game_score.record_sportsdata(game_summary, game_src)
      game_score.save
    end


    cal = Projection::FantasyPointCalculator.new
    changed_scores = []

    # iterate through each of the players in both teams of the game, updating their realtime stats.
    game_src['team'].map {|t| t['players']['player'] }.flatten.each do |player_src|

      Player.player_of_ext_id player_src["id"] do |player|
        changed = false
        stats = player_src["statistics"]
        stats.each do |name, value|
          next unless REALTIME_STATS.include? name
          # get the Live real-time score (designated by no game_score_id yet). BUGBUG: later
          #   adjust this to point to real game score reference from above, once we get rid of
          #   the old-style of real-time input.
          score = PlayerRealTimeScore.where(player: player, name: name,
                                            game_score_id:nil).first_or_initialize
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
                                            game_score_id:nil).first_or_initialize
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

