# == Schema Information
#
# Table name: players
#
#  id                :integer          not null, primary key
#  created_at        :datetime
#  updated_at        :datetime
#  sport_position_id :integer
#  salary            :integer
#  first_name        :string(255)
#  last_name         :string(255)
#  dob               :date
#  ext_player_id     :string(255)
#  team_id           :integer
#

require 'spec_helper'

describe Player do
  it { should belong_to(:sport_position) }
end
