# == Schema Information
#
# Table name: contests
#
#  id            :integer          not null, primary key
#  title         :string(255)
#  sport         :string(255)
#  contest_type  :string(255)
#  prize         :decimal(, )
#  entry_fee     :decimal(, )
#  contest_start :datetime
#  lineups_count :integer          default(0)
#  created_at    :datetime
#  updated_at    :datetime
#

require 'spec_helper'

describe Contest do
  it { should have_many(:lineups) }
  it { should have_many(:users).through(:lineups) }

end
