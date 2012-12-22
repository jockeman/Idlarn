class CreateInsults < ActiveRecord::Migration
  def self.up
    create_table :insults do |t|
      t.string :insult
    end
  end

  def self.down
    drop_table :insults
  end
end
