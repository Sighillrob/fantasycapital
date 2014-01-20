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
  
    STATS_ALLOWED = [
      "points",
      "assists",
      "steals",
      "rebounds",
      "blockedShots",
      "turnovers",
      "totalSecondsPlayed" ]
  
    COMP_STAT_KEY = [
      "made",
      "total" ]
  
    class << self

      def refresh(player, game, stats)
        stats.select {|k,v| STATS_ALLOWED.include? k}.each do |stat_n, stat_v|
          st = Stat.where(player: player, game: game, stat_name: stat_n).first_or_initialize 
          if st.new_record?
            case stat_v
            when Numeric
              st.stat_value = stat_v
            when Hash
              st.stat_value = stat_v.select {|k,v| COMP_STAT_KEY.include? k}.values.sum
            end
            st.save!
          end
        end
      end

    end
  
  end
end
