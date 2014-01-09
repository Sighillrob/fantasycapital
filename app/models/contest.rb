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

  def sport_positions
    SportPosition.where sport: self.sport
  end

  #TODO: placeholder for testing the views
  def salary_cap
    15000
  end

  def complete?
    contest_start < Time.now
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
  end

end
