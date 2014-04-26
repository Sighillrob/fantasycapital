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
    validates :ext_team_id, uniqueness: true

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
        self.defense_allowed_in_last_games(m[1].to_i)
      elsif m = /^defense_allowed_in_the_(\d+)\w\w_game_to_last$/.match(method_name)
        self.defense_allowed_in_the_game_to_last(m[1].to_i)
      else
        super
      end
    end
    
    def defense_allowed_in_last_games(x)
      Game.includes(:opponent_team, stats: :player).where(opponent_team: self).order(start_date: :asc).last(x)
    end

    def defense_allowed_in_the_game_to_last(x)
      self.defense_allowed_in_last_games(x+1).reverse[x,1]
    end

    def defense_allowed_in_home_games
      Game.includes(:opponent_team, stats: :player).where(opponent_team: self, home_team: self)
    end

    def defense_allowed_in_away_games
      Game.includes(:opponent_team, stats: :player).where(opponent_team: self, away_team: self)
    end

    def defense_allowed_in_all_games
      Game.includes(:opponent_team, stats: :player).where(opponent_team: self)
    end

  end
end
