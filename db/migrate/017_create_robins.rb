class CreateRobins < ActiveRecord::Migration
  def self.up
    create_table :robins do |t|
      t.string :comment
    end
  end

  def self.down
    drop_table :robins
  end
end
