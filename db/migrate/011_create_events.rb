class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.integer :user_id
      t.string :key
      t.string :event
      t.string :starts_at
      t.string :ends_at
      t.boolean :in_use, :default => true
      t.timestamp :created_at
    end
    add_index :events, :key, :unique => false
    add_index :events, :starts_at, :unique => false

  end
  def self.down
    drop_table :events
  end
end
