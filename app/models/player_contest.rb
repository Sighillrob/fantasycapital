class PlayerContest < ActiveRecord::Base
  belongs_to :contest
  belongs_to :player
end
