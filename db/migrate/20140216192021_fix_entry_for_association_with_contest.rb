class FixEntryForAssociationWithContest < ActiveRecord::Migration
  def change
    remove_column :entries, :player_id
    remove_column :entries, :sport
    remove_column :entries, :sport_position_id
    add_reference :entries, :contest, index: true
  end
end
