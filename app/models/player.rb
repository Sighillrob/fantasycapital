# == Schema Information
#
# Table name: players
#
#  id                :integer          not null, primary key
#  team              :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#  sport_position_id :integer
#  salary            :integer
#  stats_id          :integer
#  first_name        :string(255)
#  last_name         :string(255)
#  dob               :date
#

class Player < ActiveRecord::Base
  PRIORITIZE_SEQUENCE_NUMBER = 1
  FP_TO_SALARY_MULTIPLIER    = 250

  belongs_to :sport_position

  def name
    "#{first_name} #{last_name}"
  end

  def fantasy_points
    Projection::Player.where(stats_player_id: stats_id).first.try(:projection).try(:fp).to_f
  end

  def refresh!(player)
    self.first_name = player.first_name
    self.last_name  = player.last_name
    self.dob        = player.date_of_birth
    self.team       = player.team.name

    self.salary = FP_TO_SALARY_MULTIPLIER * self.fantasy_points
    if position = player.positions.detect {|pos| pos.sequence == PRIORITIZE_SEQUENCE_NUMBER } || player.positions.first
      player.sport_position = SportPosition.where(name: position.abbreviation, sport: 'NBA').first_or_create
    end
  end
end
