# == Schema Information
#
# Table name: player_stats
#
#  id         :integer          not null, primary key
#  player_id  :integer
#  stat_name  :string(255)
#  stat_value :string(255)
#  created_at :datetime
#  updated_at :datetime
#  dimension  :string(255)
#  time_span  :string(255)
#

class PlayerStat < ActiveRecord::Base
  belongs_to :player
end
