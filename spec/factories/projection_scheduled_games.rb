# == Schema Information
#
# Table name: projection_scheduled_games
#
#  id           :integer          not null, primary key
#  home_team_id :integer
#  away_team_id :integer
#  start_date   :datetime
#  created_at   :datetime
#  updated_at   :datetime
#  ext_game_id  :string(255)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :projection_scheduled_game, :class => 'Projection::ScheduledGame' do
    team1 nil
    team2 nil
    start_date "2014-01-16 07:17:34"
    stats_event_id 1
  end
end
