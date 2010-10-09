class Word < ActiveRecord::Base
  has_many :definitions, :dependent => :delete_all

  validates :name, :presence => true, :uniqueness => true
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
end
