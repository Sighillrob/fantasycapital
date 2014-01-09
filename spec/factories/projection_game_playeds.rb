# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :projection_game_played, :class => 'Projection::GamePlayed' do
    player nil
    game nil
  end
end
