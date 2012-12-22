class CreateJobs < ActiveRecord::Migration
  def self.up
    create_table :jobs do |t|
      t.integer :user_id
      t.string :workplace
      t.string :language
      t.string :dldr
      t.string :title
      t.string :place
      t.string :url
      t.string :description
      t.timestamp :created_at
      t.timestamp :updated_at
    end
  end

  def self.down
    drop_table :jobs
  end
end
