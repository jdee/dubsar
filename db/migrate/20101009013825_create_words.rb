class CreateWords < ActiveRecord::Migration
  def self.up
    create_table :words do |t|
      t.string :name, :null => false
      t.string :part_of_speech, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :words
  end
end
