class CreateWords < ActiveRecord::Migration
  def self.up
    create_table :words do |t|
      t.string :name, :null => false
      t.string :part_of_speech, :null => false
      t.references :synset

      t.timestamps
    end

    add_index :words, :name
    add_index :words, [ :name, :part_of_speech ]
  end

  def self.down
    drop_table :words
  end
end
