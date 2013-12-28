# == Schema Information
#
# Table name: lineups
#
#  id                :integer          not null, primary key
#  user_id           :integer
#  contest_id        :integer
#  created_at        :datetime
#  updated_at        :datetime
#  sport_position_id :integer
#

class Lineup < ActiveRecord::Base
  has_many :entries, inverse_of: :lineup
  has_many :players, through: :entries
  belongs_to :contest, inverse_of: :lineups, counter_cache: true
  belongs_to :user, inverse_of: :lineup

  accepts_nested_attributes_for :entries

  class << self
    def build_entries_for_contest(contest)
      lineup = Lineup.new contest: contest
      contest.sport_positions.order(display_priority: :asc).each do |position|
        lineup.entries.build sport_position: position
      end

      lineup
    end

  end
end
