module Projection
  class FantasyPointCalculator
    def initialize
      @stat_weights = { 
        "points" => 1,
        "assists" => 1.5,
        "steals" => 2,
        "rebounds" => 1.25,
        "blocks" => 2,
        "turnovers" => -1 }
      @games_weights = {
        "player.last_1_game" => lambda {|x| x * 0.10 },
        "player.last_3_games" => lambda {|x| x * 0.15 },
        "player.last_10_games" => lambda {|x| x * 0.25 },
        "player.all_games" => lambda {|x| x * 0.50 }
      }
    end
  
    def update(scheduled_game)
      [[scheduled_game.home_team, scheduled_game.away_team], [scheduled_game.away_team, scheduled_game.home_team]].each do |(team1, team2)|
        team1.players.each do |team1_player|
          projection = Projection.where(scheduled_game: scheduled_game, player: team1_player).first_or_create

          projection.fp = weighted_fp do |stat_name, weight|
            p_by_stat = ProjectionByStat.where(projection: projection, stat_name: stat_name).first_or_create
            p_by_stat.fp = fp_of_stat(stat_name, team1_player, team2, p_by_stat)
            p_by_stat.weighted_fp = p_by_stat.fp * weight
            p_by_stat.save!
            p_by_stat.fp
          end

          projection.save!
        end
      end
    end

    def weighted_fp(&block)
      @stat_weights.reduce(0.0) do |total, (stat_name, weight)|
        total + yield(stat_name, weight) * weight
      end
    end

    def fp_of_stat(stat_name, player, opponent_team, p_by_stat)

      p_by_stat.fp = @games_weights.reduce(0.0) do |fp, (criteria, calculation)|
        p_by_s_c = ProjByStatCrit.where(projection_by_stat: p_by_stat, criteria: criteria).first_or_create

        if ( criteria.start_with? "opponent_team" )
          p_by_s_c.fp = avg_stats_per_game(eval(criteria), p_by_s_c) {|stat| stat.stat_name == stat_name && stat.player.position == player.position}
          # opponent's stat should be factored by minutes played
          avg_mins = avg_mins_played_in_last_3(player, p_by_stat.projection)
          p_by_s_c.weighted_fp = calculation.call(p_by_s_c.fp) * avg_mins / 48.0
        else
          p_by_s_c.fp = avg_stats_per_game(eval(criteria), p_by_s_c) {|stat| stat.stat_name == stat_name && stat.player == player}
          p_by_s_c.weighted_fp = calculation.call(p_by_s_c.fp)
        end
        p_by_s_c.save!

        fp + p_by_s_c.weighted_fp
      end
    end

    def avg_mins_played_in_last_3(player, projection)
      stat_name = "minutes"
      p_by_stat = ProjectionByStat.where(projection: projection, stat_name: stat_name).first_or_create
      p_by_s_c = ProjByStatCrit.where(projection_by_stat: p_by_stat, criteria: "last_3_games").first_or_create
      p_by_s_c.fp = avg_stats_per_game(player.last_3_games, p_by_s_c) {|stat| stat.stat_name == stat_name && stat.player == player}
      p_by_stat.fp = p_by_s_c.fp
      p_by_s_c.weighted_fp = 0.0
      p_by_stat.weighted_fp = 0.0
      p_by_s_c.save!
      p_by_stat.save!
      p_by_s_c.fp
    end

    def avg_stats_per_game(games, proj_by_stat_crit=nil)
      return 0 if games.size == 0

      stats =  Stat.includes(:game, :player).where(game_id: games)
      eligible_stats = block_given? ? stats.select {|s| yield s} : stats
      eligible_stats.reduce(0.0) do |fp, stat|
        ProjectionBreakdown.where(proj_by_stat_crit: proj_by_stat_crit, stat: stat).first_or_create unless proj_by_stat_crit.nil?
        fp += stat.stat_value || 0.0
      end / games.size
    end

    def method_missing(method_name, *args, &block)
      if @stat_weights.keys.include?(method_name.to_s)
        @stat_weights[method_name.to_s] = args[0]
      elsif @games_weights.keys.include?(method_name.to_s.sub("__", "."))
        @games_weights[method_name.to_s.sub("__", ".")] = args[0]
      else
        super
      end
    end

  end
end
