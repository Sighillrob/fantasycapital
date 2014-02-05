# == Schema Information
#
# Table name: players
#
#  id                :integer          not null, primary key
#  team              :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#  sport_position_id :integer
#  salary            :integer
#  stats_id          :integer
#  first_name        :string(255)
#  last_name         :string(255)
#  dob               :date
#

class Player < ActiveRecord::Base
  belongs_to :sport_position

  def name
    "#{first_name} #{last_name}"
  end
end
