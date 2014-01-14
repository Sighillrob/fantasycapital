# == Schema Information
#
# Table name: projection_games
#
#  id           :integer          not null, primary key
#  gamedate     :datetime
#  is_home      :boolean
#  created_at   :datetime
#  updated_at   :datetime
#  home_team_id :integer
#  away_team_id :integer
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :projection_game, :class => 'Projection::Game' do
    gamedate "2014-01-07"
    is_home false
  end
end
