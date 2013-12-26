# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :player do
    name "Quincy Acy"
    team "Tor"
    age 23
    sport_position
  end
end
