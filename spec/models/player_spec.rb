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

require 'spec_helper'

describe Player do
  it { should belong_to(:sport_position) }
  it { should have_many(:entries) }
end
