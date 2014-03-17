class AddActionHistory < ActiveRecord::Migration
  def self.up
    create_table :action_histories do |t|
      t.integer :user_id
      t.string :action
      t.string :parameters
      t.timestamp :created_at
    end
  end

  def self.down
    drop_table :action_histories
  end
end
