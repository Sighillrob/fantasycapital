# == Schema Information
#
# Table name: game_scores
#
#  id              :integer          not null, primary key
#  playdate        :date
#  ext_game_id     :string(255)
#  scheduledstart  :datetime
#  home_team_id    :integer
#  away_team_id    :integer
#  home_team_score :integer
#  away_team_score :integer
#  status          :string(255)
#  clock           :string(255)
#  period          :integer
#  created_at      :datetime
#  updated_at      :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :game_score do
    playdate "2014-03-12"
    scheduled_game ""
    actualstart "2014-03-12 17:14:57"
    actualend "2014-03-12 17:14:57"
    home_team_score 1
    away_team_score 1
  end
end
