class CreateUserstats < ActiveRecord::Migration
  def self.up
    create_table :userstats do |t|
      t.integer :user_id
      t.integer :channel_id
      t.integer :lines, :default => 0
      t.integer :words, :default => 0
      t.string  :quote
      t.timestamp :created_at
    end
  end
  def self.down
    drop_table :userstats
  end
end
