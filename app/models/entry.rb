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
  has_one    :contest, through: :lineup

  validates :lineup_id, uniqueness: {scope: :user_id, message: "You already have entry for this live up"}


  class << self

    def live
      joins(:contest).where "contests.contest_start BETWEEN ? AND ?", DateTime.now, DateTime.now + 3.hour
    end

    def completed
      joins(:contest).where "contests.contest_start < ?", DateTime.now
    end

    def upcoming
      joins(:contest).where "contests.contest_start > ?", DateTime.now
    end

    def for_day(day)
      joins(:contest).where "contests.contest_start BETWEEN ? AND ?", day.beginning_of_day, day.end_of_day
    end

    def for_sport(sport)
      joins(:contest).where "contests.contests.sport = ?", sport
    end
  end
end
