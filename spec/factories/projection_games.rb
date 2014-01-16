# == Schema Information
#
# Table name: projection_games
#
#  id               :integer          not null, primary key
#  start_date       :datetime
#  created_at       :datetime
#  updated_at       :datetime
#  team_id          :integer
#  opponent_team_id :integer
#  stats_event_id   :integer
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :projection_game, :class => 'Projection::Game' do
    start_date "2014-01-07"
  end
end
