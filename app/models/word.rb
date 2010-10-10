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

  # abbreviation for the full part_of_speech
  def pos
    sym = self.class.pos(part_of_speech)
    sym ? sym.to_s : ''
  end

  class << self
    def pos(part_of_speech)
      case part_of_speech.to_sym
      when :adjective
        :adj
      when :adverb
        :adv
      when :conjunction
        :conj
      when :interjection
        :interj
      when :noun
        :n
      when :preposition
        :prep
      when :pronoun
        :pron
      when :verb
        :v
      else
      end
    end
  end
end
