class StatService
    def initialize
      @stat_map = { 
        "fp" => "FPPG",
        "personal_fouls" => "PFPG",
        "minutes" => "MPG",
        "points" => "PPG",
        "assists" => "APG",
        "steals" => "STLPG",
        "rebounds" => "RPG",
        "blocks" => "BLKPG",
        "turnovers" => "TOPG",
      }
      @dimension_map = {
        "p_player." => "summary",
        "p_opponent_team.defense_allowed_in_" => "matchup" }
      @span_map = {
        "the_0th_game_to_last" => lambda {|games| games[0].start_date},
        "the_1rd_game_to_last" => lambda {|games| games[0].start_date},
        "the_2nd_game_to_last" => lambda {|games| games[0].start_date},
        "home_games" => lambda {|games| "Home Games"},
        "away_games" => lambda {|games| "Away Games"},
        "all_games" => lambda {|games| "2013 season"}
      }

    end
  
    def update_player_stats(scheduled_game)
      cal = Projection::FantasyPointCalculator.new
      [[scheduled_game.home_team, scheduled_game.away_team], [scheduled_game.away_team, scheduled_game.home_team]].each do |(team1, team2)|
        team1.players.each do |p_player|
          player = Player.where(ext_player_id: p_player.ext_player_id).first
          next if player.nil?
          player.player_stats.delete_all
          p_opponent_team = team2

          @dimension_map.each do |subject, dim_display|
            @span_map.each do |span, span_display|
              @stat_map.each do |stat_name, stat_display|
                games = eval(subject + span)
                next if games.nil? || games.size == 0
                stat_value = cal.avg_stats_per_game(games) {|stat| stat.stat_name == stat_name && stat.player == p_player}
                PlayerStat.create(dimension: dim_display, time_span: span_display.call(games), stat_name: stat_display, stat_value: stat_value.to_s, player: player)
              end # of stat
            end # of span
          end # of dim
        end # of player
      end # of team

    end

end
