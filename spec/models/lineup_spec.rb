# == Schema Information
#
# Table name: lineups
#
#  id         :integer          not null, primary key
#  entry_id   :integer
#  player_id  :integer
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'

describe Lineup do
  it { should belong_to(:player) }
  it { should belong_to(:entry) }
end
