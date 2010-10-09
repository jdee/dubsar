class Word < ActiveRecord::Base
  belongs_to :synset
  has_many :definitions, :dependent => :delete_all

  validates :name, :presence => true
  validates :part_of_speech, :presence => true,
    :inclusion => { :in =>
    %w{adjective
       adverb
       conjunction
       interjection
       noun
       preposition
       pronoun
       verb} }

  def synonyms
    synset.words.reject{ |w| w == self }.map{ |w| w.name } if synset
  end
end
