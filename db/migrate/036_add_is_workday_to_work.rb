class AddIsWorkdayToWork < ActiveRecord::Migration
  def self.up
    add_column :works, :is_workday, :boolean, :default => true
  end

  def self.down
    remove_column :works, :is_workday
  end
end
