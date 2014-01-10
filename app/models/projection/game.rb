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
end
