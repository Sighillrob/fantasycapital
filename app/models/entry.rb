# == Schema Information
#
# Table name: entries
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  sport      :string(255)
#  created_at :datetime
#  updated_at :datetime
#  contest_id :integer
#

class Entry < ActiveRecord::Base
  belongs_to :contest
  belongs_to :user, inverse_of: :entries
  has_many :lineups, inverse_of: :entry
  has_many :players, through: :lineups
end
