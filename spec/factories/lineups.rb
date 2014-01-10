# == Schema Information
#
# Table name: lineups
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  contest_id :integer
#  created_at :datetime
#  updated_at :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :lineup do
    contest nil
    user nil
  end
end
