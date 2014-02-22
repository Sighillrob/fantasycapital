# == Schema Information
#
# Table name: entries
#
#  id         :integer          not null, primary key
#  lineup_id  :integer
#  created_at :datetime
#  updated_at :datetime
#  contest_id :integer
#

class Entry < ActiveRecord::Base
  belongs_to :lineup, inverse_of: :entries
  belongs_to :contest, inverse_of: :entries, counter_cache: true

  validates :lineup, :contest, presence: true

  validate :number_of_entries
 
  def number_of_entries
    errors.add(:contest, "Number of entries can't exceed maximum.") if contest.entries.count >= contest.max_entries 
  end

  class << self

    def live
      joins(:contest).for_day(DateTime.now).where "contests.contest_start <= ? AND contests.contest_end >= ?", DateTime.now, DateTime.now
    end

    def completed
      joins(:contest).for_day(DateTime.now).where "contests.contest_end < ?", DateTime.now
    end

    def upcoming
      joins(:contest).for_day(DateTime.now).where "contests.contest_start > ?", DateTime.now
    end

    def for_day(day)
      joins(:contest).where "contests.contest_start BETWEEN ? AND ?", day.beginning_of_day, day.end_of_day
    end

    def for_sport(sport)
      joins(:contest).where "contests.contests.sport = ?", sport
    end
  end
end
