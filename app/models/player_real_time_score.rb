# == Schema Information
#
# Table name: player_real_time_scores
#
#  id            :integer          not null, primary key
#  name          :string(255)
#  value         :decimal(, )
#  player_id     :integer
#  created_at    :datetime
#  updated_at    :datetime
#  game_score_id :integer
#

class PlayerRealTimeScore < ActiveRecord::Base
  validates :player_id, presence: true
  validates :game_score, presence: true

  belongs_to :player
  belongs_to :game_score
end
