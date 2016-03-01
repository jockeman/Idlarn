class AddBloodtype < ActiveRecord::Migration
  def self.up
    add_column :users, :bloodtype, :string
  end

  def self.down
    remove_column :users, :bloodtype
  end
end
