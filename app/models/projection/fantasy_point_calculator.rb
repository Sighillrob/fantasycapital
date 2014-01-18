module Projection
  class FantasyPointCalculator


    def initialize
      @stat_weights = { 
        "points" => 1,
        "assists" => 1.5,
        "steals" => 2,
        "rebounds" => 1.25,
        "blockedShots" => 2,
        "turnovers" => -1 }
      @games_weights = {
        "player.last_1_game" => 0.15,
        "player.last_3_games" => 0.15,
        "player.last_10_games" => 0.20,
        "opponent_team" => 0.50
      }
    end
  
    def update(player, opponent_team, projection)

      projection.fp = @stat_weights.reduce(0.0) do |fp, (stat_name, weight)|
        p_by_stat = ProjectionByStat.where(projection: projection, stat_name: stat_name).first_or_create
        p_by_stat.fp = fp_of_stat(stat_name, player, opponent_team, p_by_stat)
        p_by_stat.weighted_fp = p_by_stat.fp * weight
        p_by_stat.save!

        fp + p_by_stat.weighted_fp
      end

    end

    def fp_of_stat(stat_name, player, opponent_team, p_by_stat)
      p_by_stat.fp = @games_weights.reduce(0.0) do |fp, (criteria, weight)|
        p_by_s_c = ProjByStatCrit.where(projection_by_stat: p_by_stat, criteria: criteria).first_or_create

        if ( criteria == "opponent_team" )
          p_by_s_c.fp = team_stat(opponent_team, player.position, stat_name)
        else
          p_by_s_c.fp = avg_stat(eval(criteria), player, stat_name)
        end

        p_by_s_c.weighted_fp = p_by_s_c.fp * weight
        p_by_s_c.save!
      end
    end

    def avg_stat(games, player, stat_name)
      stats = games.reduce([]) {|stats, game| stats + game.stats}
      stats.select do |stat|
        stat.stat_name == stat_name && stat.player == player
      end.reduce(0.0) do |fp, stat|
        fp += stat.stat_value.to_f
      end / games.size
    end

    def team_stat(team, position, stat_name)
      games = Game.includes(:opponent_team, stats: :player).where(opponent_team: team).order(start_date: :desc).limit(10)
      return 0 if games.size == 0
      stats = games.reduce([]) {|stats, game| stats + game.stats}
      stats.select do |stat|
        stat.stat_name == stat_name && stat.player.position == position
      end.reduce(0.0) do |fp, stat|
        fp += stat.stat_value.to_f
      end / games.size
    end

    def method_missing(method_name, *args, &block)
      if @stat_weights.keys.include?(method_name.to_s)
        @stat_weights[method_name.to_s] = args[0]
      else
        super
      end
    end

  end
end
