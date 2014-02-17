# == Schema Information
#
# Table name: entries
#
#  id                :integer          not null, primary key
#  user_id           :integer
#  lineup_id         :integer
#  player_id         :integer
#  sport             :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#  sport_position_id :integer
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :entry do
    contest nil
    user nil
  end
end
