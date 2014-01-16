# == Schema Information
#
# Table name: projection_scheduled_games
#
#  id             :integer          not null, primary key
#  home_team_id   :integer
#  away_team_id   :integer
#  start_date     :datetime
#  stats_event_id :integer
#  created_at     :datetime
#  updated_at     :datetime
#

module Projection
  class ScheduledGame < ActiveRecord::Base
    belongs_to :home_team, class_name: Team
    belongs_to :away_team, class_name: Team

    class << self
      def refresh_all(stats_events)
        stats_events.each &method(:find_or_create_for_stats)
      end

      def find_or_create_for_stats(stats_game)
        game = ScheduledGame.where(stats_event_id: stats_game["eventId"]).first_or_initialize
    
        if game.new_record?
          game.start_date = StatsClient::ResponseParser::DatetimeParser.parse stats_game["startDate"]
          stats_game["teams"].each do |stats_team|
            game[%Q[#{stats_team['teamLocationType']['name']}_team_id].to_sym] = (Team.find_by_stats_team_id stats_team['teamId']).id
           end
          game.save!
        end
      end
    end

  end
end
