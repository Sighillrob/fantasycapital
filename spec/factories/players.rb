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
    first_name "Quincy"
    last_name "Acy"
    team "Tor"
    dob { Date.today - 15.year }
    sport_position
  end
end
