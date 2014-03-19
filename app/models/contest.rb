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
#  created_at    :datetime
#  updated_at    :datetime
#  max_entries   :integer
#  contest_end   :datetime
#  entries_count :integer          default(0)
#

class Contest < ActiveRecord::Base
  validates :contestdate, presence: true

  has_many :entries, inverse_of: :contest
  has_many :player_contests, inverse_of: :contest
  has_many :eligible_players, source: :player, through: :player_contests

  has_many :lineups, through: :entries
  has_many :users, through: :lineups

  def start!
    # mark contest as started right now.
    self.contest_start = Time.now
    self.contest_end = Time.now + 60*60*2
    update({contest_start: self.contest_start, contest_end: self.contest_end})
    # send as an array of one contest update.
    Pusher['gamecenter'].trigger('stats', { "contests" => [{id: self.id, live: true}] })


  end

  def end!
    # mark contest as finished right now.
    self.contest_end = Time.now
    update({contest_end: self.contest_end})
    Pusher['gamecenter'].trigger('stats', { "contests" => [{id: self.id, live: false}] })

  end

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

  def live?
    # is current contest live right now?
    contest_start < DateTime.now && contest_end > DateTime.now
  end


  def filled?
    max_entries.nil? ? false : entries.count >= max_entries.to_i
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

    def upcoming(user=nil, date=Time.now.in_time_zone("US/Eastern").to_date)

      where("contestdate >= ?", date).order(
              contestdate: :asc, contest_type: :asc, entry_fee: :asc).select do |c|
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

    def pretty_contest_name
      "#{number_to_currency(self.prize, unit: '$')} #{self.sport} #{selfcontest_type}"
    end

    def as_json(options = { })
      # add computed parameters for json serialization (for sending to browser)
      h = super(options)
      h[:pretty_contest_name]   = self.pretty_contest_name
      h
    end


  end

end
