class CreateSemesters < ActiveRecord::Migration
  def self.up
    create_table :semesters do |t|
      t.integer :user_id
      t.datetime :starts_at
      t.datetime :ends_at
    end
  end

  def self.down
    drop_table :semesters
  end
end
