class Projection::Game < ActiveRecord::Base
  belongs_to :home_team, class_name: Projection::Team
  belongs_to :opponent_team, class_name: Projection::Team
end
