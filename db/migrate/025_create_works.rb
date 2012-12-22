class CreateWorks < ActiveRecord::Migration
  def self.up
    create_table :works do |t|
      t.integer :user_id
      t.integer :start_hour
      t.integer :end_hour
      t.integer :start_min
      t.integer :end_min
      t.integer :workday
    end
  end

  def self.down
    drop_table :works
  end
end
