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
