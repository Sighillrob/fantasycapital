# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :projection_game, :class => 'Projection::Game' do
    gamedate "2014-01-07 16:29:35"
    is_home false
  end
end
