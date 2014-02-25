# == Schema Information
#
# Table name: projection_teams
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#  is_current  :boolean
#  ext_team_id :string(255)
#

module Projection
  class Team < ActiveRecord::Base
    has_many :games, inverse_of: :team
    has_many :players, inverse_of: :team
  
    class << self
      def refresh_all(teams_src)
        Team.update_all(is_current: false)
        updated_teams = []
        teams_src.each do |team_src|
          team = Team.where(ext_team_id: team_src["id"]).first_or_create
          team.name = team_src["name"]
          team.is_current = true;
          team.save!
          updated_teams << team
        end
        updated_teams
      end
    end

    def method_missing(method_name, *args, &block)
      if m = /^defense_allowed_in_last_(\d+)_game[s]*$/.match(method_name)
        self.defense_allowed_in_last_games(m[1].to_i, args)
      else
        super
      end
    end
    
    def defense_allowed_in_last_games(x, position)
      Stat.where( player: self, game_id: (GamePlayed.includes(:game).where(player: self).sort { |a,b| a.game.start_date <=> b.game.start_date}.last(x).map {|x| x.game} ) )
    end

  end
end
