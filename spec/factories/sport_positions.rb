# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :sport_position do
    name "SF"
    sport "NBA"
    display_priority 0
  end
end