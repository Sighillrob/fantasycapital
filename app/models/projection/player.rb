# == Schema Information
#
# Table name: projection_players
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#  fp              :decimal(, )
#  team_id         :integer
#  is_current      :boolean
#  stats_player_id :integer
#  position        :string(255)
#

module Projection
  class Player < ActiveRecord::Base
    belongs_to :team
    has_paper_trail :ignore => [:stats_player_id, :name]

    class << self
      # refresh players with STATS API response
      def refresh(stats_players)
        Player.update_all(is_current: false)
        stats_players.each do |stats_player|
          player = Player.where(stats_player_id: stats_player.player_id).first_or_create
          player.name = stats_player.first_name + " " + stats_player.last_name
          player.is_current = true;
          player.team = Team.find_by_stats_team_id(stats_player.team['teamId'])
          player.position = (stats_player.positions.select {|p| p['sequence'] ==1}).first['abbreviation']
          player.save!
        end
      end
    end
  end
end
