# == Schema Information
#
# Table name: projection_players
#
#  id            :integer          not null, primary key
#  name          :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#  team_id       :integer
#  is_current    :boolean
#  position      :string(255)
#  ext_player_id :string(255)
#

module Projection
  class Player < ActiveRecord::Base
    belongs_to :team
    has_one :projection

    class << self
      def refresh(players_src, team)
        team.players.update_all(is_current: false)
        players_src.each do |player_src|
          player = Player.where(ext_player_id: player_src['id']).first_or_initialize
          player.name = player_src['full_name']
          player.is_current = true
          player.team = team
          player.position = player_src['primary_position']
          player.save!
        end
      end
    end

    def method_missing(method_name, *args, &block)
      if m = /^last_(\d+)_game[s]*$/.match(method_name)
        self.last_games(m[1].to_i)
      elsif m = /^the_(\d+)\w\w_game_to_last$/.match(method_name)
        self.the_game_to_last(m[1].to_i)
      else
        super
      end
    end
    
    def last_games(x)
      GamePlayed.includes(:game).where(player: self).sort { |a,b| a.game.start_date <=> b.game.start_date}.last(x).map {|g| g.game} 
    end

    def the_game_to_last(x)
      self.last_games(x+1).reverse[x,1]
    end

    def home_games
      GamePlayed.includes(:game).where(player: self, "projection_games.home_team_id" => self.team).map {|g| g.game} 
    end

    def away_games
      GamePlayed.includes(:game).where(player: self, "projection_games.away_team_id" => self.team).map {|g| g.game} 
    end

    def all_games
      GamePlayed.includes(:game).where(player: self).map {|g| g.game} 
    end

  end
end
