# == Schema Information
#
# Table name: entries
#
#  id                :integer          not null, primary key
#  user_id           :integer
#  lineup_id         :integer
#  player_id         :integer
#  sport             :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#  sport_position_id :integer
#

require 'spec_helper'

describe Entry do
  it { should belong_to(:user) }
  it { should belong_to(:lineup) }
  it { should belong_to(:player) }
  it { should belong_to(:sport_position) }
  it { should validate_presence_of(:player) }
end
