# == Schema Information
#
# Table name: player_perf_indices
#
#  id          :integer          not null, primary key
#  player_id   :integer
#  index_name  :string(255)
#  index_value :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

class PlayerPerfIndex < ActiveRecord::Base
  belongs_to :player
end
