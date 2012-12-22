class CreateAlts < ActiveRecord::Migration
  def self.up
    create_table :alts do |t|
      t.integer :user_id
      t.string :nick
      t.timestamp :last_use
    end
  end

  def self.down
    drop_table :alts
  end
end
