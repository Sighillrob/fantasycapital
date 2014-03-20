# == Schema Information
#
# Table name: teams
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  teamalias   :string(255)
#  ext_team_id :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

class Team < ActiveRecord::Base
  has_many :players
end