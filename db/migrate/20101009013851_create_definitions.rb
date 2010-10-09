class CreateDefinitions < ActiveRecord::Migration
  def self.up
    create_table :definitions do |t|
      t.references :word
      t.string :body, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :definitions
  end
end
