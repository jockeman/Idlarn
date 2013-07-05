class CreateMixes < ActiveRecord::Migration
  def self.up
    create_table :mixes do |t|
      t.integer :user_id
      t.string :url
      t.timestamp :created_at
    end
  end

  def self.down
    drop_table :mixes
  end
end
