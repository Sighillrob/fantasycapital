# == Schema Information
#
# Table name: lineups
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  contest_id :integer
#  created_at :datetime
#  updated_at :datetime
#

class Lineup < ActiveRecord::Base
  has_many :entries, inverse_of: :lineup
  has_many :lineup_spots, inverse_of: :lineup
  has_many :players, through: :entries
  belongs_to :contest, inverse_of: :lineups, counter_cache: true
  belongs_to :user, inverse_of: :lineup

  accepts_nested_attributes_for :entries, :lineup_spots

  class << self
    def build_for_contest(contest)
      lineup = Lineup.new contest: contest
      LineupSpotProto.where(sport: contest.sport).order(spot: :asc).each do |proto|
        lineup.lineup_spots.build sport_position: SportPosition.find_by_sport_and_name(proto.sport, proto.sport_position_name), spot: proto.spot
      end
      lineup
    end

  end
end
