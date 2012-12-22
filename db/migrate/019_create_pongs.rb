class CreatePongs < ActiveRecord::Migration
  def self.up
    create_table :pongs do |t|
      t.text :url
      t.integer :user_id
      t.datetime :created_at
      t.string :pong
    end
  end

  def self.down
    drop_table :pongs
  end
end
