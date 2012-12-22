class CreateActions < ActiveRecord::Migration
  def self.up
    create_table :actions do |t|
      t.integer :user_id
      t.integer :channel_id
      t.timestamp :timestamp
      t.string :action_type
      t.string :action
    end
  end

  def self.down
    drop_table :actions
  end
end
