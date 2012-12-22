class AddOldz < ActiveRecord::Migration
  def self.up
    add_column :users, :oldz, :integer, :default => 0
  end

  def self.down
    remove_column :users, :oldz
  end
end
