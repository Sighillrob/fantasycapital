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

class Projection::Player < ActiveRecord::Base
  belongs_to :team
  has_paper_trail :ignore => [:ext_player_id, :player_name]
end
