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
#  first_name        :string(255)
#  last_name         :string(255)
#  dob               :date
#  ext_player_id     :string(255)
#

class Player < ActiveRecord::Base
  PRIORITIZE_SEQUENCE_NUMBER = 1
  FP_TO_SALARY_MULTIPLIER    = 250
  PLAYER_MIN_SALARY = 3000

  belongs_to :sport_position

  def name
    "#{first_name} #{last_name}"
  end

  def fantasy_points
    Projection::Projection.where(player_id: Projection::Player.where(ext_player_id: ext_player_id).first).order(updated_at: :desc).first.try(:fp) || 0
  end

  def self.refresh_all(players_src, team_src)
    players_src.each do |player_src|
      player = Player.where(ext_player_id: player_src['id']).first_or_initialize
      player.last_name = player_src['last_name']
      player.first_name = player_src['first_name']
      player.team = team_src['name']
      player.dob = Time.parse(player_src['birthdate'])

      #salary is fp * 250 rounded to nearest 100
      salary = (player.fantasy_points * FP_TO_SALARY_MULTIPLIER / 100.0).round * 100
      #min 3000
      player.salary = [salary, PLAYER_MIN_SALARY].max

      player.sport_position = SportPosition.where(name: player_src['primary_position'], sport: 'NBA').first
      player.save!
    end
  end
end
