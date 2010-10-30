class AddIndicesToWords < ActiveRecord::Migration
  def self.up
    add_index :words, :name
    add_index :words, [ :name, :part_of_speech ]
  end

  def self.down
    remove_index :words, :name
    remove_index :words, [ :name, :part_of_speech ]
  end
end
