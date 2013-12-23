# == Schema Information
#
# Table name: players
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  team       :string(255)
#  sport_position_id   :integer
#  age        :integer
#  created_at :datetime
#  updated_at :datetime
#

class Player < ActiveRecord::Base
  belongs_to :sport_position

  module Positions
    SF = 'SF'
    F  = 'F'
    C  = 'C'
    PF = 'PF'
    SG = 'SG'
    FC = 'F-C'
    PG = 'PG'
    G  = 'G'
  end

  class << self
    def on_position(pos)
      where position: pos.to_s
    end
  end
end
