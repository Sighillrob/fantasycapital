# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :projection_player, :class => 'Projection::Player' do
    ext_player_id "MyString"
    player_name "MyString"
  end
end
