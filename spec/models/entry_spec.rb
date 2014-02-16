# == Schema Information
#
# Table name: entries
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  lineup_id  :integer
#  created_at :datetime
#  updated_at :datetime
#  contest_id :integer
#

require 'spec_helper'

describe Entry do
  it { should belong_to(:user) }
  it { should belong_to(:lineup) }
end
