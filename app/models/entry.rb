# == Schema Information
#
# Table name: entries
#
#  id                :integer          not null, primary key
#  user_id           :integer
#  lineup_id         :integer
#  player_id         :integer
#  sport             :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#  sport_position_id :integer
#

class Entry < ActiveRecord::Base
  belongs_to :user, inverse_of: :entries
  belongs_to :lineup, inverse_of: :entries
end
