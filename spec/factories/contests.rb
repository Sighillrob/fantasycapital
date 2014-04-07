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
#  created_at    :datetime
#  updated_at    :datetime
#  max_entries   :integer
#  entries_count :integer          default(0)
#  contestdate   :date
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :contest do
    sport "NBA"
    contest_type "50/50"
    entry_fee 1.0
    prize 1.9
    contestdate Time.now.to_date + 1    # default is contests start tomorrow.
    contest_start  Time.now + 60*60*12  # 12 hours from now
    max_entries 10
  end
end
