class CorrectUVerbInflections < ActiveRecord::Migration
  @words = %w{quit equip quip acquit quiz squat}

  def self.up
    @words.each do |word|
      w = Word.find_by_name_and_part_of_speech word, 'verb'
      inflection = w.inflections.find :first, :conditions => "name ~ '[ai][ptz]ing'"
      w.inflections.delete inflection
      inflection.destroy
      w.save
    end
  end

  def self.down
    @words.each do |word|
      w = Word.find_by_name_and_part_of_speech word, 'verb'
      w.inflections.create :name => word.name + 'ing'
      w.save
    end
  end
end
