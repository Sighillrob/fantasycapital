# == Schema Information
#
# Table name: contests
#
#  id            :integer          not null, primary key
#  title         :string(255)
#  sport         :string(255)
#  contest_type  :string(255)
#  prize         :decimal(, )
#  entry_fee     :decimal(, )
#  contest_start :datetime
#  lineups_count :integer          default(0)
#  created_at    :datetime
#  updated_at    :datetime
#  max_entries   :integer
#

class Contest < ActiveRecord::Base
  has_many :entries, inverse_of: :contest

  #TODO: placeholder for testing the views
  def salary_cap
    65000
  end

  def start_at
    self.class.for_day(self.contest_start).for_sport(self.sport).order('contest_start ASC').first.contest_start
  end

  def complete?
    start_at < DateTime.now
  end

  def filled?
    entries.count >= max_entries
  end

  def eligible_for?(user)
    if user.nil?
      true
    else
      max_entries_per_user = (contest_type.downcase == "tournament") ? 5 : 1
      user.entries.select {|e| e.contest == self}.count < max_entries_per_user
    end
  end

  def enter(lineup)
    raise "#{lineup.user} maximized the number of entries" unless eligible_for? lineup.user
    raise "Maximum entries reached" if filled?
    dup.save! if entries.count == max_entries - 1
    entries.create(lineup: lineup)
  end

  class << self

    def live
      where "contest_start BETWEEN ? AND ?", DateTime.now - 3.hour, DateTime.now + 3.hour
    end

    def completed
     where "contest_start < ?", DateTime.now
    end

    def upcoming(user=nil)
      where("contest_start > ?", DateTime.now).order(contest_type: :asc, entry_fee: :asc).select do |c|
        (! c.filled?) && c.eligible_for?(user)
      end
    end

    def for_day(day)
      where "contest_start BETWEEN ? AND ?", day.beginning_of_day, day.end_of_day
    end

    def for_sport(sport)
      where sport: sport
    end

    def sport_names
      group(:sport).pluck(:sport)
    end
  end

end
