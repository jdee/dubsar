class AdjustManInflections < ActiveRecord::Migration
  @words = %w{brahman caiman ceriman dolman hanuman human liman roman saman shaman soman talisman zaman}
  def self.up
    @words.each do |word|
      w = Word.find_by_name_and_part_of_speech word, 'noun'
      w.inflections.each do |inflection|
        next if inflection.name == w.name
        w.inflections.delete inflection
        inflection.destroy
      end

      w.inflections.create :name => w.name + 's'
      w.save
    end

    Word.find_by_name_and_part_of_speech('dragoman', 'noun').inflections.create :name => 'dragomans'
  end

  def self.down
    @words.each do |word|
      w = Word.find_by_name_and_part_of_speech word, 'noun'
      w.inflections.each do |inflection|
        next if inflection.name == w.name
        w.inflections.delete inflection
        inflection.destroy
      end

      w.inflections.create :name => w.name.pluralize
      w.save
    end

    w = Word.find_by_name_and_part_of_speech('dragoman', 'noun')
    inflection = w.inflections.find(:first, :conditions => ['name = ?', 'dragomans'])
    w.inflections.delete inflection
    inflection.destroy
    w.save
  end
end
