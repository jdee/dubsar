class AddFreqCntAndNameIndexToWords < ActiveRecord::Migration
  def self.up
    add_index :words, [ :freq_cnt, :name ]
  end

  def self.down
    remove_index :words, [ :freq_cnt, :name ]
  end
end
