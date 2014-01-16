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
#  stats_event_id   :integer
#

module Projection
  class Game < ActiveRecord::Base
    belongs_to :team, class_name: Projection::Team
    belongs_to :opponent_team, class_name: Projection::Team
    has_many :stats, inverse_of: :game
  
    def self.find_or_create_for_stats(stats_game)
      game = Game.where(
        team: (Team.find_by_stats_team_id stats_game["team"]['teamId']), 
        stats_event_id: stats_game["eventId"]
      ).first_or_initialize
  
      if game.new_record?
        game.start_date = StatsClient::ResponseParser::DatetimeParser.parse stats_game["startDate"]
        game.opponent_team = Team.find_by_stats_team_id stats_game["opponentTeam"]['teamId']
        game.save!
      end
      game
    end

  end
end
