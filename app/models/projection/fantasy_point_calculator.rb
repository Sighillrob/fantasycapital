module Projection
  class FantasyPointCalculator


    def initialize(player)
      @fp_ratios = { 
        "points" => 1,
        "assists" => 1.5,
        "steals" => 2,
        "rebounds" => 1.25,
        "blockedShots" => 2,
        "turnovers" => -1 }
      @player = player
    end
  
    def fp(opponent_team)
      self.instance_eval(File.read("#{Rails.root}/config/projection_model"), File.read("#{Rails.root}/config/projection_model"))
      @fp_ratios.reduce(0) do |fp, (stat_name, ratio)|
        fp + ratio * (
          aggregated_stat(@player.last_1_game, @player.position, stat_name) * 0.15
          + aggregated_stat(@player.last_3_games, @player.position, stat_name) * 0.15
          + aggregated_stat(@player.last_10_games, @player.position, stat_name) * 0.20
          + team_stat(opponent_team, @player.position, stat_name) * 0.50
          )
      end
    end

    def team_stat(team, position, stat_name)
      last_10_games = Game.includes(:opponent_team, stats: :player).where(opponent_team: team).order(start_date: :desc).limit(10)
      aggregated_stat(last_10_games, position, stat_name)
    end

    def aggregated_stat(games, position, stat_name)
      stats = games.reduce([]) {|stats, game| stats + game.stats}
      stats.select do |stat|
        stat.stat_name == stat_name && stat.player.position == position
      end.reduce(0) do |fp, stat|
        fp += stat.stat_value
      end
    end

    def method_missing(method_name, *args, &block)
      if @fp_ratios.keys.include?(method_name.to_s)
        @fp_ratios[method_name.to_s] = args[0]
      else
        super
      end
    end

  end
end
