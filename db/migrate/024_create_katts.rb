class CreateKatts < ActiveRecord::Migration
  def self.up
    create_table :katts do |t|
      t.string :skemt
    end
  end

  def self.down
    drop_table :katts
  end
end
