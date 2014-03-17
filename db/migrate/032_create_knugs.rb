class CreateKnugs < ActiveRecord::Migration
  def self.up
    create_table :knugs do |t|
      t.integer :user_id
      t.string :url
      t.timestamp :created_at
    end
  end

  def self.down
    drop_table :knugs
  end
end
