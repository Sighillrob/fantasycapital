class AddIdToEntrys < ActiveRecord::Migration
  def change
    add_column :entries, :id, :integer
  end
end
