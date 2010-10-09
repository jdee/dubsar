class AddSynonymsToWords < ActiveRecord::Migration
  def self.up
    add_column :words, :synonyms, :string
  end

  def self.down
    remove_column :words, :synonyms
  end
end
