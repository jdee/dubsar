class ChangeWords < ActiveRecord::Migration
  def self.up
    add_index :words, :name
    change_column :words, :name, :string, :unique => true, :null => false
  end

  def self.down
    change_column :words, :name, :string, :unique => false, :null => false
    remove_index :words, :name
  end
end
