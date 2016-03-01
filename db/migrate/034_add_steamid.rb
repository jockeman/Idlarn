class AddSteamid < ActiveRecord::Migration
  def self.up
    add_column :users, :steamid, :string
  end

  def self.down
    remove_column :users, :steamid
  end
end
