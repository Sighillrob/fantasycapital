# == Schema Information
#
# Table name: projection_scheduled_games
#
#  id           :integer          not null, primary key
#  home_team_id :integer
#  away_team_id :integer
#  start_date   :datetime
#  created_at   :datetime
#  updated_at   :datetime
#  ext_game_id  :string(255)
#

module Projection
  class ScheduledGame < ActiveRecord::Base
    belongs_to :home_team, class_name: Team
    belongs_to :away_team, class_name: Team

    class << self
      def refresh_all(games_src)
        games_src.each do |game_src|
          game = ScheduledGame.where(ext_game_id: game_src["id"]).first_or_initialize
          game.start_date = Time.parse(game_src["scheduled"])
          home_team = Team.find_by_ext_team_id game_src["home_team"]
          away_team = Team.find_by_ext_team_id game_src["away_team"]
          unless home_team && away_team
            logger.warn "Either #{game_src["home_team"]} or #{game_src["away_team"]} is not found..."
            logger.warn "Skipping #{game_src}"
            next
          end
          game.home_team = home_team
          game.away_team = away_team
          game.save!
        end
      end
    end

  end
end
