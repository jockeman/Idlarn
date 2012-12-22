class AddRandomAction < ActiveRecord::Migration
  def self.up
    add_column :channel_users, :random_action, :string
    add_column :channel_users, :random_time, :timestamp
    add_column :channel_users, :action_msg, :string
  end

  def self.down
    remove_column :channel_users, :random_action
    remove_column :channel_users, :random_time
    remove_column :channel_users, :action_msg
  end
end
