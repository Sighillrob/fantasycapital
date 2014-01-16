# == Schema Information
#
# Table name: projection_players
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#  team_id         :integer
#  is_current      :boolean
#  stats_player_id :integer
#  position        :string(255)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :projection_player, :class => 'Projection::Player' do
    ext_player_id "MyString"
    player_name "MyString"
    team
  end
end
