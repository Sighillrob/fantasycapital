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

  def current_fantasypoints
    # returns total fantasy points of the entry at the moment
    playdate = self.contest.contestdate
    gameids = GameScore.where({playdate: playdate}).pluck('id')
    lineup.players.map { |player| player.realtime_fantasy_points(gameids) }.sum
  end

  def as_json(options = { })
    # add computed parameters for json serialization (for sending to browser)
    h = super(options)
    h[:username]   = self.lineup.user.username
    h[:fps] = self.current_fantasypoints
    h[:player_ids] = self.lineup.lineup_spots.pluck('player_id')
    h
  end

  class << self

    def live
      # live, more loosely defined, means entries that are happening today.
      joins(:contest).where "contests.contestdate = ?", Time.now.in_time_zone("US/Pacific").to_date
    end

    def completed
      joins(:contest).where "contests.contest_end < ?", DateTime.now
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
