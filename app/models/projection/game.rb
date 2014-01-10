# == Schema Information
#
# Table name: projection_games
#
#  id         :integer          not null, primary key
#  gamedate   :datetime
#  is_home    :boolean
#  created_at :datetime
#  updated_at :datetime
#

class Projection::Game < ActiveRecord::Base
  belongs_to :home_team, class_name: Projection::Team
  belongs_to :opponent_team, class_name: Projection::Team
end
