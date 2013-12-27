# == Schema Information
#
# Table name: lineups
#
#  id         :integer          not null, primary key
#  entry_id   :integer
#  player_id  :integer
#  created_at :datetime
#  updated_at :datetime
#

class Lineup < ActiveRecord::Base
  belongs_to :entry, inverse_of: :lineups
  belongs_to :player
end
