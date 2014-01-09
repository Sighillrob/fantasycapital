class Projection::Player < ActiveRecord::Base
  belongs_to :team
  has_paper_trail :ignore => [:ext_player_id, :player_name]
end
