# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :contest do
    sport "NBA"
    contest_type "50/50"
    enrtry_fee 1.0
    prize 1.9
    contest_start  Time.now + 60*60*12
  end
end
