class AddBirthdate < ActiveRecord::Migration
  def self.up
    add_column :users, :birthdate, :timestamp
  end

  def self.down
    remove_column :users, :timestamp
  end
end
