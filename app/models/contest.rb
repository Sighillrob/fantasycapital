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
#

class Contest < ActiveRecord::Base
  has_many :lineups, inverse_of: :contest
  has_many :users, through: :lineups

  before_create :setup_contest

  def sport_positions
    SportPosition.where sport: self.sport
  end

  #TODO: placeholder for testing the views
  def salary_cap
    15000
  end

  def start_at
    self.class.for_day(self.contest_start).for_sport(self.sport).order('contest_start ASC').first.contest_start
  end

  def complete?
    start_at < DateTime.now
  end

  def lineup_for_user(user)
    lineups.where(user_id: user.id).first
  end

  class << self

    def live
      where contest_start: DateTime.now .. DateTime.now + 3.hour
    end

    def completed
     where "contest_start < ?", DateTime.now
    end

    def upcoming
      where "contest_start > ?", DateTime.now
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

  protected

  def setup_contest
    self.entry_fee ||= 10
    self.prize     = 2 * self.entry_fee * 0.95
    self.contest_type = '50/50 '
  end

end
