class Word < ActiveRecord::Base
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

  def add_synonym(synonym)
    # first check to see if it's already there
    return if include_synonym?(synonym)
    synonyms += ',' + synonym
  end

  def each_synonym
    synonyms.split(',').each { |synonym| yield synonym }
  end

  def include_synonym?(synonym)
    synonyms.split(',').include?(synonym)
  end
end
