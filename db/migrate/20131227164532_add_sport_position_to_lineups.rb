class AddSportPositionToLineups < ActiveRecord::Migration
  def change
    add_reference :lineups, :sport_position, index: true
  end
end
