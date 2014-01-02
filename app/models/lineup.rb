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
  has_many :lineup_spots, inverse_of: :lineup, dependent: :destroy
  has_many :players, through: :lineup_spots
  belongs_to :contest, inverse_of: :lineups, counter_cache: true
  belongs_to :user, inverse_of: :lineups

  before_save :mark_unused_spot_for_removal

  accepts_nested_attributes_for :entries
  accepts_nested_attributes_for :lineup_spots, allow_destroy: true

  validates :contest, presence: true

  class << self
    def build_for_contest(contest, lineup = nil)
      lineup = Lineup.find_by_id(lineup) || Lineup.new({contest: contest})

      LineupSpotProto.where(sport: contest.sport).order(spot: :asc).each do |proto|
        if lineup.lineup_spots.find_by_spot(proto.spot).blank?
          lineup.lineup_spots.build sport_position: SportPosition.find_by_sport_and_name(proto.sport, proto.sport_position_name),
                                    spot: proto.spot
        end
      end

      lineup
    end

  end

  protected
  def mark_unused_spot_for_removal
    lineup_spots.each do |spot|
      spot.mark_for_destruction if spot.player.blank?
    end
  end
end
