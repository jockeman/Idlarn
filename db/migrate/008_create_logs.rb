class CreateLogs < ActiveRecord::Migration
  def self.up
    create_table :logs do |t|
      t.integer :user_id
      t.string :actiontype
      t.string :message
      t.integer :channel_id
      t.timestamp :created_at
    end
  end
  def self.down
    drop_table :logs
  end
end
