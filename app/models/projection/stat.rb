# == Schema Information
#
# Table name: projection_stats
#
#  id         :integer          not null, primary key
#  stat_name  :string(255)
#  stat_value :decimal(, )
#  player_id  :integer
#  game_id    :integer
#  created_at :datetime
#  updated_at :datetime
#

module Projection
  class Stat < ActiveRecord::Base
    belongs_to :game
    belongs_to :player
  
    STATS_ALLOWED = { 
      "fp" => nil,
      "points" => nil,
      "assists" => nil,
      "steals" => nil,
      "rebounds" => nil,
      "blocks" => nil,
      "turnovers" => nil,
      "personal_fouls" => nil,
      "minutes" => lambda {|x| (m,s) = x.split(":"); m.to_f + s.to_f/60.0}
    }
  
    class << self

      def refresh(player, game, stats)
        stats.select {|k,v| STATS_ALLOWED.keys.include? k}.each do |stat_n, stat_v|
          st = Stat.where(player: player, game: game, stat_name: stat_n).first_or_initialize 
          st.stat_value = STATS_ALLOWED[stat_n] ? STATS_ALLOWED[stat_n].call(stat_v) : stat_v
          st.save!
        end
      end

    end
  
  end
end
