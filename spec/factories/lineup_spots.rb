# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :lineup_spot do
    sport_position nil
    lineup nil
    player nil
    spot 1
  end
end
