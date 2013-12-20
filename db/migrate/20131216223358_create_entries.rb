class CreateEntries < ActiveRecord::Migration
  def change
    create_table :entries do |t|
      t.references :user, index: true
      t.references :contest, index: true
      t.string :sport

      t.timestamps
    end
  end
end
