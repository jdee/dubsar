class CreateSynsetsWords < ActiveRecord::Migration
  def self.up
    create_table :synsets_words, :id => false do |t|
      t.references :synset
      t.references :word
    end
  end

  def self.down
    drop_table :synsets_words
  end
end
