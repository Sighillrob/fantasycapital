# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :sport_position do
    name "MyString"
    sport "MyString"
    display_priority 1
  end
end
