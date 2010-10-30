class AddFreqCntToWords < ActiveRecord::Migration
  def self.up
    add_column :words, :freq_cnt, :integer, :null => false, :default => 0
  end

  def self.down
    remove_column :words, :freq_cnt
  end
end
