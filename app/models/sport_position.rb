class SportPosition < ActiveRecord::Base
  has_many :players, inverse_of: :sport_position
end
