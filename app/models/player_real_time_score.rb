# == Schema Information
#
# Table name: player_real_time_scores
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  value      :decimal(, )
#  player_id  :integer
#  created_at :datetime
#  updated_at :datetime
#

class PlayerRealTimeScore < ActiveRecord::Base
  belongs_to :player
end
