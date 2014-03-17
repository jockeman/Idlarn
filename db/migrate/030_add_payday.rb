class AddPayday < ActiveRecord::Migration
  def self.up
    add_column :users, :payday, :integer, :default => 25
  end

  def self.down
    remove_column :users, :payday
  end
end
