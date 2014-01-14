# == Schema Information
#
# Table name: projection_players
#
#  id            :integer          not null, primary key
#  ext_player_id :string(255)
#  player_name   :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#  fp            :decimal(, )
#  team_id       :integer
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :projection_player, :class => 'Projection::Player' do
    ext_player_id "MyString"
    player_name "MyString"
    team
  end
end
