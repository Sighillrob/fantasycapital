# == Schema Information
#
# Table name: projection_games
#
#  id               :integer          not null, primary key
#  start_date       :datetime
#  created_at       :datetime
#  updated_at       :datetime
#  team_id          :integer
#  opponent_team_id :integer
#  ext_game_id      :string(255)
#  home_team_id     :integer
#  away_team_id     :integer
#

module Projection
  class Game < ActiveRecord::Base
    belongs_to :team
    belongs_to :opponent_team, class_name: Team
    belongs_to :home_team, class_name: Team
    belongs_to :away_team, class_name: Team
    has_many :stats, inverse_of: :game
  
    def self.refresh_all(games_src, cutoff=(Time.now-10.days))
      updated_games = []
      games_src.select {|g| g["status"] == "closed"}.each do |game_src|

        game_start = Time.parse(game_src["scheduled"])
        next if game_start < cutoff

        home_team = Team.find_by_ext_team_id game_src["home_team"]
        away_team = Team.find_by_ext_team_id game_src["away_team"]
        unless home_team && away_team
          logger.warn "Either #{game_src["home_team"]} or #{game_src["away_team"]} is not found..."
          logger.warn "Skipping #{game_src}"
          next
        end

        teams = [home_team, away_team];
        [teams, teams.reverse].each do |(team1, team2)|
          game = Game.where( team: team1, ext_game_id: game_src["id"] ).first_or_initialize
          game.start_date = game_start
          game.opponent_team = team2
          game.home_team = home_team
          game.away_team = away_team
          game.save!
          updated_games << game
        end
      end
      updated_games
    end

    def refresh_stats(teams_src)
      teams_src.select {|t| t["id"] == team.ext_team_id}.each do |team_src|
        team_src['players']['player'].select {|x| x['played']  && x['played'] == 'true'}.each do |player_src|
          player = Player.find_by_ext_player_id player_src["id"]
          if player.nil?
            logger.warn "#{player_src["id"]} not found...."
            logger.warn "Skipping #{player_src}"
            next
          end
          GamePlayed.where(player: player, game: self).first_or_create
          fp = Projection.joins(:scheduled_game).where(player: player, projection_scheduled_games: {ext_game_id: self.ext_game_id}).reduce(0.0) {|sum, p| p.fp}
          Stat.refresh player, self, player_src["statistics"].merge({"fp"=>fp})
        end
      end
    end

  end
end
