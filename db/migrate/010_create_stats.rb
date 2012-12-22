class CreateStats < ActiveRecord::Migration
  def self.up
    create_table :dailystats do |t|
      t.integer :channel_id
      t.integer :user_id
      t.date :day
      t.integer :words, :default => 0
      t.integer :lines, :default => 0
      t.integer :joins, :default => 0
      t.integer :quits, :default => 0
      t.string :quote
      t.timestamp :created_at
    end
    create_table :hourlystats do |t|
      t.integer :dailystat_id
      t.integer :hour
      t.integer :words, :default => 0
      t.integer :lines, :default => 0
      t.integer :joins, :default => 0
      t.integer :quits, :default => 0
      t.string :quote
      t.timestamp :created_at
    end
  end
  def self.down
    drop_table :dailystats
    drop_table :hourlystats
  end
end
