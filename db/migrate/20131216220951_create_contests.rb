class CreateContests < ActiveRecord::Migration
  def change
    create_table :contests do |t|
      t.string :title
      t.string :sport
      t.string :contest_type
      t.decimal :prize
      t.decimal :enrtry_fee
      t.datetime :contest_start

      t.timestamps
    end
  end
end
