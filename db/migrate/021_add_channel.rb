class AddChannel < ActiveRecord::Migration
  def self.up
    add_column :urls, :channel, :string
  end

  def self.down
    remove_column :urls, :channel
  end
end
