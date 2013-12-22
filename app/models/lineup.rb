class Lineup < ActiveRecord::Base
  belongs_to :entry, inverse_of: :lineups
  belongs_to :player
end
