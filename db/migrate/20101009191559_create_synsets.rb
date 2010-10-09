class CreateSynsets < ActiveRecord::Migration
  def self.up
    create_table :synsets do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :synsets
  end
end
