# == Schema Information
#
# Table name: sport_positions
#
#  id               :integer          not null, primary key
#  name             :string(255)
#  sport            :string(255)
#  display_priority :integer
#  created_at       :datetime
#  updated_at       :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :sport_position do
    name "SF"
    sport "NBA"
    display_priority 0
  end
end
