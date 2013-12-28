# == Schema Information
#
# Table name: entries
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  lineup_id  :integer
#  player_id  :integer
#  sport      :string(255)
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'

describe Entry do
  it { should belong_to(:contest) }
  it { should belong_to(:user) }
  it { should have_many(:lineups) }
  it { should have_many(:players).through(:lineups) }

end
