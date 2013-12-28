# == Schema Information
#
# Table name: lineups
#
#  id                :integer          not null, primary key
#  user_id           :integer
#  contest_id        :integer
#  created_at        :datetime
#  updated_at        :datetime
#  sport_position_id :integer
#

require 'spec_helper'

describe Lineup do
  it { should belong_to(:player) }
  it { should belong_to(:entry) }
end
