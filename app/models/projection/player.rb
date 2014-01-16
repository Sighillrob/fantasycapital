# == Schema Information
#
# Table name: projection_players
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#  team_id         :integer
#  is_current      :boolean
#  stats_player_id :integer
#  position        :string(255)
#

module Projection
  class Player < ActiveRecord::Base
    belongs_to :team

    class << self
      # refresh players with STATS API response
      def refresh_all(stats_players)
        Player.update_all(is_current: false)
        stats_players.each do |stats_player|
          player = Player.where(stats_player_id: stats_player.player_id).first_or_initialize
          player.name = stats_player.first_name + " " + stats_player.last_name
          player.is_current = true
          player.team = Team.find_by_stats_team_id(stats_player.team['teamId'])
          player.position = (stats_player.positions.select {|p| p['sequence'] ==1}).first['abbreviation']
          player.save!
        end
      end
    end

  
    # refresh one player stats with STATS API response
    def refresh_stats(stats_games)
      stats_games.select {|g| g["playerStats"]["totalSecondsPlayed"] > 0}.each do |stats_game|
        game = Game.find_or_create_for_stats stats_game
        GamePlayed.where(player: self, game: game).first_or_create
        Stat.refresh self, game, stats_game["playerStats"]
      end
    end
  end
end
