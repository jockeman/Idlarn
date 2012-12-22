class CreateHaddocks < ActiveRecord::Migration
  def self.up
    create_table :haddocks do |t|
      t.string :insult
    end
  end

  def self.down
    drop_table :haddocks
  end
end
