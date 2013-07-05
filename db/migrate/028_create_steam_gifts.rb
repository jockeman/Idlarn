class CreateSteamGifts < ActiveRecord::Migration
  def self.up
    create_table :steam_gifts do |t|
      t.integer :user_id
      t.string :game_name
      t.boolean :gifted
      t.timestamp :created_at
    end
  end

  def self.down
    drop_table :steam_gifts
  end
end
