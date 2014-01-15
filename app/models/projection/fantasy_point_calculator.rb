module Projection
  class FantasyPointCalculator

    FP_RATIOS = { 
      "points" => 1,
      "assists" => 1.5,
      "steals" => 2,
      "rebounds" => 1.25,
      "blockedShots" => 2,
      "turnovers" => -1 }

    def initialize(player)
      @player = player
    end
  
    def fp(opponent_team)
      games_played = GamePlayed.includes(:game).where(player: @player).sort { |a,b| a.game.start_date <=> b.game.start_date}
      last_game = games_played.last(1).map {|x| x.game} 
      last_3_games = games_played.last(3).map {|x| x.game} 
      last_10_games = games_played.last(10).map {|x| x.game} 

      FP_RATIOS.reduce(0) do |fp, (stat_name, ratio)|
        fp + ratio * (
          aggregated_stat(last_game, @player.position, stat_name) * 0.15
          + aggregated_stat(last_3_games, @player.position, stat_name) * 0.15
          + aggregated_stat(last_10_games, @player.position, stat_name) * 0.20
          + team_stat(opponent_team, @player.position, stat_name) * 0.50
          )
      end
    end

    def team_stat(team, position, stat_name)
      last_10_games = Game.includes(:opponent_team, stats: :player).where(team: team).order(start_date: :desc).limit(10)
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

  end
end
