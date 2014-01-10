# == Schema Information
#
# Table name: projection_players
#
#  id            :integer          not null, primary key
#  ext_player_id :string(255)
#  player_name   :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#

class Projection::Player < ActiveRecord::Base
end
