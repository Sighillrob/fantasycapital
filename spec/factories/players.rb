# == Schema Information
#
# Table name: players
#
#  id                :integer          not null, primary key
#  team              :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#  sport_position_id :integer
#  salary            :integer
#  stats_id          :integer
#  first_name        :string(255)
#  last_name         :string(255)
#  dob               :date
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
