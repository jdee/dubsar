class CreateSynsets < ActiveRecord::Migration
  def self.up
    create_table :synsets do |t|
      t.text :definition, :null => false
    end
  end

  def self.down
    drop_table :synsets
  end
end
