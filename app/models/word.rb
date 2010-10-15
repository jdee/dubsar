require 'string'

# A single +Word+ entry represents a word and part of speech.  For
# example, _run_ will have two separate entries as a noun and a verb.
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

  # Array of strings
  def synonyms
    synset.words.reject{ |w| w == self }.map{ |w| w.name } if synset
  end

  # Abbreviation for the full part_of_speech
  def pos
    sym = self.class.pos(part_of_speech)
    sym ? sym.to_s : ''
  end

  # generates an identifier (no spaces) from the word's name and
  # part of speech
  def unique_name
    (name.capitalized? ? 'cap-' : '') + "#{name.gsub(' ', '_')}_#{pos}"
  end

  class << self
    # Map the full part of speech (as a symbol or string) to its
    # abbreviation.  Returns a symbol, one of:
    # - <tt>:adj</tt>
    # - <tt>:adv</tt>
    # - <tt>:conj</tt>
    # - <tt>:interj</tt>
    # - <tt>:n</tt>
    # - <tt>:prep</tt>
    # - <tt>:pron</tt>
    # - <tt>:v</tt>
    def pos(part_of_speech)
      { :adjective    => :adj,
        :adverb       => :adv,
        :conjunction  => :conj,
        :interjection => :interj,
        :noun         => :n,
        :preposition  => :prep,
        :pronoun      => :pron,
        :verb         => :v
      }[part_of_speech.to_sym]
    end
  end
end
