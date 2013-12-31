# == Schema Information
#
# Table name: players
#
#  id                :integer          not null, primary key
#  name              :string(255)
#  team              :string(255)
#  age               :integer
#  created_at        :datetime
#  updated_at        :datetime
#  sport_position_id :integer
#

class Player < ActiveRecord::Base
  belongs_to :sport_position

  #TODO: stub method for testing remaining salary cap in lineup
  def salary
    @salary ||= rand(5500)
    @salary
  end

end
