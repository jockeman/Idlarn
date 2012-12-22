class CreateChannelUsers < ActiveRecord::Migration
  def self.up
    create_table :channel_users do |t|
      t.integer :user_id
      t.integer :channel_id
      t.timestamp :last_active
      t.string :last_action
      t.boolean :oper
      t.boolean :voice
    end
  end

  def self.down
    drop_table :channel_users
  end
end
