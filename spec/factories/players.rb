# == Schema Information
#
# Table name: players
#
#  id                :integer          not null, primary key
#  name              :string(255)
#  team              :string(255)
#  age               :integer
#  created_at        :datetime
#  updated_at        :datetime
#  sport_position_id :integer
#  salary            :integer
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :player do
    name "Quincy Acy"
    team "Tor"
    age 23
    sport_position
  end
end
