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

class Projection::Stat < ActiveRecord::Base
  belongs_to :game
  belongs_to :player
end
