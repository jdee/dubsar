class DropFairies < ActiveRecord::Migration
  def self.up
    drop_table :fairies
  end

  def self.down
    create_table :fairies do |t|
      t.string :name , :null => false
      t.string :email, :null => false
      t.string :phone_number

      t.timestamps
    end
  end
end
