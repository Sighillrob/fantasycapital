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

  accepts_nested_attributes_for :lineups

  class << self
    def build_entry_for_contest(contest)
      entry = Entry.new contest: contest
      contest.sport_positions.order(display_priority: :asc).each do |position|
        entry.lineups.build sport_position: position
      end

      entry
    end

  end
end
