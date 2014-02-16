# == Schema Information
#
# Table name: lineups
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  created_at :datetime
#  updated_at :datetime
#  sport      :string(255)
#

require 'spec_helper'

describe Lineup do
  it { should belong_to(:contest) }
  it { should belong_to(:user) }
  it { should have_many(:players).through(:lineup_spots) }

end
