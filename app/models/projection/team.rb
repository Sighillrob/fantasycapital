# == Schema Information
#
# Table name: projection_teams
#
#  id            :integer          not null, primary key
#  name          :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#  stats_team_id :integer
#  is_current    :boolean
#

module Projection
  class Team < ActiveRecord::Base
  
    class << self
      # refresh teams with STATS API response
      def refresh_all(stats_teams)
        Team.update_all(is_current: false)
        stats_teams.each do |stats_team|
          team = Team.where(stats_team_id: stats_team.team_id).first_or_create
          team.name = stats_team.name
          team.is_current = true;
          team.save!
        end
      end
    end
  end
end
