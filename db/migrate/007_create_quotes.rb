class CreateQuotes < ActiveRecord::Migration
  def self.up
    create_table :quotes do |t|
      t.integer :user_id
      t.integer :adder
      t.integer :channel_id
      t.timestamp :timestamp
      t.text :quote
    end
  end

  def self.down
    drop_table :quotes
  end
end
