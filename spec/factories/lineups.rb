# == Schema Information
#
# Table name: lineups
#
#  id         :integer          not null, primary key
#  entry_id   :integer
#  player_id  :integer
#  created_at :datetime
#  updated_at :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :lineup do
    entry nil
    Player nil
  end
end
