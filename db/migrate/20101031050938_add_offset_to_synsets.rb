class AddOffsetToSynsets < ActiveRecord::Migration
  def self.up
    add_column :synsets, :offset, :integer
    add_column :synsets, :part_of_speech, :string
  end

  def self.down
    remove_column :synsets, :part_of_speech
    remove_column :synsets, :offset
  end
end
