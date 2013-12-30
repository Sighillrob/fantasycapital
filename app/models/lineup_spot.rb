class LineupSpot < ActiveRecord::Base
  belongs_to :sport_position
  belongs_to :lineup
  belongs_to :player
end
