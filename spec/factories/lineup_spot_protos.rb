# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :lineup_spot_proto do
    sport "MyString"
    sport_position_name "MyString"
    spot 1
  end
end
