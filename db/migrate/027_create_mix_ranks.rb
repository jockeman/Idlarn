class CreateMixRanks < ActiveRecord::Migration
  def self.up
    create_table :mix_ranks do |t|
      t.integer :user_id
      t.integer :mix_id
      t.integer :rank
      t.timestamp :created_at
    end
  end

  def self.down
    drop_table :mix_ranks
  end
end
