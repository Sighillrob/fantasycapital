class CreateEntries < ActiveRecord::Migration
  def change
    create_table :entries, :id => false do |t|
      t.integer :user_id
      t.integer :contest_id

      t.timestamps
    end
  end
end
