class CreateLineups < ActiveRecord::Migration
  def change
    create_table :lineups do |t|
      t.references :entry, index: true
      t.references :player, index: true

      t.timestamps
    end
  end
end
