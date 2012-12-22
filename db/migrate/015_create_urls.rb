class CreateUrls < ActiveRecord::Migration
  def self.up
    create_table :urls do |t|
      t.string :url
      t.integer :user_id
      t.datetime :created_at
      t.integer :times
    end
  end

  def self.down
    drop_table :urls
  end
end
