class CreateHyllas < ActiveRecord::Migration
  def self.up
    create_table :hyllas do |t|
      t.string :hyllning
    end
  end

  def self.down
    drop_table :hyllas
  end
end
