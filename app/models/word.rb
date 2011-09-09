#  Dubsar Dictionary Project
#  Copyright (C) 2010-11 Jimmy Dee
#
#  This program is free software; you can redistribute it and/or
#  modify it under the terms of the GNU General Public License
#  as published by the Free Software Foundation; either version 2
#  of the License, or (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

require 'string'

class Hash
  def search_options
    raise 'no search term specified' unless self[:term]

    copy = clone_without_controller_params
    table = :inflections # by default
    match = copy.delete(:match)

    conditions = case match
    when nil, ''
      term = copy.delete(:term)
      if /[%_\[\]?*+.()]/ =~ term
        table = :words
        "words.name LIKE ?"
      else
        "inflections.name LIKE ?"
      end
    when 'case'
      if /[%_\[\]?*+.()]/ =~ copy[:term]
        table = :words
        term = copy.delete(:term).gsub('%', '*').gsub('_', '?')
        "words.name GLOB ?"
      else
        term = copy.delete(:term)
        "inflections.name = ?"
      end
    when 'regexp'
      # only supported for backward compatibility with the iPad 1.0.1
      # client; always expect term to be '^[character-class]'
      table = :words
      term = copy.delete(:term).sub(/^\^/, '') + "*"
      "words.name GLOB ?"
    when 'exact'
      term = copy.delete(:term)
      "inflections.name = ?"
    end

    case table
    when :inflections
      copy.merge!(
        :conditions => [ conditions, term ],
        :joins => 'INNER JOIN inflections ON words.id = inflections.word_id')
    when :words
      copy.merge! :conditions => [ conditions, term ]
    end
    copy.merge!(:page => copy[:page]) if copy.has_key?(:page)
    copy.symbolize_keys
  end

  private

  def clone_without_controller_params
    copy = clone
    copy.delete(:action)
    copy.delete(:back)
    copy.delete(:commit)
    copy.delete(:controller)
    copy.delete(:format)
    copy.delete(:title)
    copy.delete(:utf8)
    copy
  end
end

class String
  def double_consonant?
    case self
    when /mortar$/
      false
    when /[bs]lur$/, /spur$/, /[bc]ur$/, /demur$/, /ir$/,
      /[ens]fer$/, /^(dis|)inter$/, /deter$/, /abhor$/, /^aver$/,
      /char$/, /[bcjmptw]ar$/
      true
    when /^grin$/, /^[cd]on$/, /^t[hw]in$/, /^[bcfw]an$/, /^[dgps]un$/,
      /^[bdfgstw]in$/, /^stun$/, /^s[hkp]in$/, /^chin$/, /^scan$/,
      /^plan$/, /^shun$/, /^swan$/, /^[py]en$/, /^begin$/, /tan$/,
      /run$/, /man$/, /pin$/, /pan$/
      true
    when /^gel$/, /^fulfil$/, /^corral$/, /^instal$/, /^appal$/,
      /^enthral$/, /^pal$/, /^excel$/, /pel$/, /stil$/
      true
    when /^audit$/, /^benefit$/, /^exit$/, /^orbit$/, /^profit$/,
      /^vomit$/, /credit$/, /habit$/, /comfit$/, /edit$/, /debit$/,
      /limit$/, /posit$/, /inherit$/, /spirit$/, /licit$/, /hibit$/,
      /rabbit$/, /merit$/, /visit$/, /^summit$/, /^transit$/
      false
    # -uit (like quit) is handled in local_exceptional_verb
    when /[^aeiou][aeiouy]t$/
      true
    else
      false
    end
  end
end

# A single +Word+ entry represents a word and part of speech.  For
# example, _run_ will have two separate entries as a noun and a verb.
class Word < ActiveRecord::Base
  before_save :compute_freq_cnt
  has_many :senses, :order => 'freq_cnt DESC, id ASC'
  has_many :synsets, :through => :senses,
    :order => 'senses.freq_cnt DESC, senses.id ASC'
  has_many :inflections, :order => 'inflections.name ASC'

  validates :name, :presence => true
  validates :freq_cnt, :presence => true
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

  def initialize(*args)
    options = args && args.first
    irregulars = options.delete(:irregular) if (options && options.is_a?(Hash))

    super

    irregulars.each { |i| inflections.build :name => i } if irregulars

    add_regular_inflections
    remove_duplicate_inflections
  end

  def <=>(other)
    name <=> other.name
  end

  def button_label
    text = "#{name} (#{pos}.)"
    text += " freq. cnt.: #{freq_cnt}" if freq_cnt > 0
    text += "; also #{other_forms}" if other_forms.length > 0
  end

  def page_title
    "Dubsar - #{name} (#{pos}.)"
  end

  def meta_description
    description = "Dubsar Dictionary Project Word entry for #{name} (#{pos}.)"
    description += " freq. cnt.: #{freq_cnt}" unless freq_cnt.zero?
    description += " (#{other_forms})" unless other_forms.blank?
    case senses.count
    when 1
      description += "; 1 word sense"
    else
      description += "; #{senses.count} word senses"
    end
    description
  end

  # Abbreviation for the full part_of_speech
  def pos
    sym = self.class.pos(part_of_speech)
    sym ? sym.to_s : ''
  end

  def name_and_pos
    "#{name} (#{pos}.)"
  end

  # generates an identifier (no spaces) from the word's name and
  # part of speech
  def unique_name
    (name.capitalized? ? 'cap-' : '') +
      "#{name.downcase.gsub(/[\s.']/, '_')}_#{pos}"
  end

  def create_new_inflection(name)
    inflections.create(:name => name) unless inflections.map(&:name).include?(name)
  end

  def build_new_inflection(name)
    inflections.build(:name => name) unless inflections.map(&:name).include?(name)
  end

  def add_regular_inflections
    # DEBT: Should subclass and have this handled polymorphically,
    # but for now there's not much here.

    # Only attempt regular inflection of words that contain no
    # capitals, numbers, spaces, hyphens or other punctuation.
    if name =~ /^[a-z]+$/
      case
      when part_of_speech.blank?
        return # invalid anyway
      when inflections.empty?
        method = "add_regular_#{part_of_speech}_inflections"
        self.send method
      when part_of_speech == 'verb'
        # verbs have to be handled in more detail
        add_regular_verb_inflections
      end
    end

    add_self_inflection
  end

  def other_forms
    inflections.find(:all, :conditions => [ 'name != ?', name ],
      :order => 'name').map{|infl|infl.name}.join(', ')
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

    # Search for words matching the specified term.
    # Takes a hash of options:
    #   <tt>:term</tt> _required_ search term
    #   <tt>:match</tt> one of 'browse', 'case', 'exact', 'regexp' or '' (default - case insensitive)
    #   <tt>:page</tt> optional page number (for will_paginate)
    # Pass any additiona options to <tt>:find,</tt> particularly
    #   <tt>:limit</tt>
    #   <tt>:offset</tt>
    # which are used in JSON requests.
    def search(options={})
      options = options.symbolize_keys
      return nil unless options[:term]

      if options.has_key?(:offset)
        all options.search_options
      else
        paginate options.search_options
      end
    end

    def search_count(options={})
      return 0 unless options[:term]
      search_options = options.search_options
      search_options.delete(:page)
      count search_options
    end

    # Select a Word entry from the DB at random. Must be all lowercase
    # with no spaces or punctuattion, at least <tt>min_length</tt>
    # letters (9 by default).
    def random_word(min_length=9)
      pattern = ''
      min_length.times do
        pattern += '[a-z]'
      end

      words = Word.all(:conditions => [ "name GLOB '#{pattern}*' AND NOT name GLOB ?",
        "*[A-Z0-9 .-']*" ], :select => 'id')
      random_number = SecureRandom.random_number(words.count)
      Word.find words[random_number].id
    end
  end

  def remove_duplicate_inflections
    inflections.each do |i|
      inflections.delete(i) if
        inflections.select{|j|j.name == i.name}.length > 1
    end
  end

  def compute_freq_cnt
    self.freq_cnt = senses.sum :freq_cnt
  end

  private

  # Handle some things that aren't in WordNet and are not well
  # handled by active_support.
  def local_exceptional_noun
    case name
    when /^dragoman$/
      inflections.build :name => name + 's'
      false
    when /^brahman$/, /^caiman$/, /^ceriman$/, /^dolman$/,
      /^hanuman$/, /^human$/, /^liman$/, /^roman$/,
      /^saman$/, /^shaman$/, /^soman$/, /^talisman$/, /^zaman$/
      inflections.build :name => name + 's'
      true
    else
      false
    end
  end

  def local_exceptional_verb
    case name
    when /^quiz$/
      build_new_inflection name + 'zes'
      build_new_inflection name + 'zed'
      build_new_inflection name + 'zing'
      true
    when /quip$/
      build_new_inflection name + 's'
      build_new_inflection name + 'ped'
      build_new_inflection name + 'ping'
      true
    when /quit$/, /squat$/
      build_new_inflection name + 's'
      build_new_inflection name + 'ted'
      build_new_inflection name + 'ting'
      true
    when /hurt$/
      build_new_inflection name + 's'
      build_new_inflection name + 'ing'
      true
    when /[^aeio]et$/
      if inflections.empty?
        inflections.build :name => name + 'ed'
        inflections.build :name => name + 'ing'
      end
      build_new_inflection name + 's'
      true
    when /[ai]c$/
      if inflections.empty?
        inflections.build :name => name + 'ked'
        inflections.build :name => name + 'king'
      end
      build_new_inflection name + 's'
      true
    else
      false
    end
  end

  def add_regular_adjective_inflections
    # These end up looking absurd much of the time
  end

  def add_regular_adverb_inflections
    # There are no regular adverb inflections
  end

  def add_regular_noun_inflections
    # Use the active_support inflector for regular nouns.
    inflections.build :name => name.pluralize unless local_exceptional_noun
  end

  def add_regular_verb_inflections
    return if local_exceptional_verb

    build_past_tense
    build_third_person_singular
    build_present_participle
  end

  def add_self_inflection
    build_new_inflection name
  end

  def build_present_participle
    return unless part_of_speech == 'verb'
    # Based on vagaries of the WN exceptions, this seems like the
    # right thing to do, but needs review.
    return if inflections.any? { |i| i.name =~ /[ny]ing$/ }

    case name
    when /^.e$/
      # pretty much just being, but would also produce things like meing
      build_new_inflection name + 'ing'
    when /[^e]e$/
      build_new_inflection name.sub(/e$/, 'ing')
    when /[^aeiou][aeiouy][lnrt]$/
      c = /[^aeiou][aeiouy]([lnrt])$/.match(name)[1]
      l = name.double_consonant? ? c : ''
      build_new_inflection name + l + 'ing'
    else
      case pad
      when 's'
        build_new_inflection name + pad + 'ing'
        build_new_inflection name + 'ing'
      else
        build_new_inflection name + pad + 'ing'
      end
    end
  end

  def build_third_person_singular
    return unless part_of_speech == 'verb'
    case name
    when 'be', 'have'
      # very limited set of verbs with irregular third-person singular
      # present tense
      # (do nothing)
      return
    when /[osxz]$/, /(ch|sh)$/
      inflections.build :name => name + 'es'
      case pad
      when 's'
        # e.g., buses and busses as the present tense of bus
        inflections.build :name => name + 'es'
        inflections.build :name => name + pad + 'es'
      end
    when /[^aeou]y$/
      inflections.build :name => name.sub(/y$/, 'ies')
    else
      inflections.build :name => name + 's'
    end
  end

  def build_past_tense
    # DEBT: Assume any irregular verb in WordNet has an irregular past
    # tense.  (Is this true of all English verbs?)
    #
    # Also, any verb that has a past participle different from its past
    # tense (2nd and 3rd principle parts) is irregular.  WordNet does
    # not distinguish semantically among verb conjugations.  It only
    # presents different forms for each word, as we do here.  So for
    # regular verbs, we do not construct a past participle, only a past
    # tense.
    return unless part_of_speech == 'verb' and inflections.empty?

    case name
    when /e$/
      build_new_inflection name + 'd'
    when /[^aeou]y$/
      build_new_inflection name.sub(/y$/, 'ied')
    when /[^aeiou][aeiouy][lnrt]$/
      c = /[^aeiou][aeiouy]([lnrt])$/.match(name)[1]
      l = name.double_consonant? ? c : ''
      build_new_inflection name + l + 'ed'
    else
      case pad
      when /^[n]$/
        build_new_inflection name + 'ed'
      when /^[ls]$/
        build_new_inflection name + pad + 'ed'
        build_new_inflection name + 'ed'
      else
        build_new_inflection name + pad + 'ed'
      end
    end
  end

=begin
  # This code is unused.
  def comparative_degree
    return '' unless part_of_speech == 'adjective'
    case name
    when /e$/
      name + 'r'
    when /y$/
      name.sub /y$/, 'ier'
    else
      name + pad + 'er'
    end
  end

  def superlative_degree
    return '' unless part_of_speech == 'adjective'
    case name
    when /e$/
      name + 'st'
    when /y$/
      name.sub /y$/, 'iest'
    else
      name + pad + 'est'
    end
  end
=end

  def pad
    # A word taking an -e... (-ed, -es, etc.) or -ing ending that ends
    # in consonant-vowel-consonant has the last consonant doubled
    # before adding the ending.  (Words ending in E are treated
    # elsewhere.) We treat Y as a vowel in the last two positions, but
    # not the first.

    # Match:
    # yes => yessing (pad = s)
    # pad => padding (pad = d)

    # Don't match (so no padding):
    # fail => failing (a is a vowel)
    # cloy => cloying (y is treated like a vowel in the last position)
    # snow => snowing
    md = name.match /[^aeiou][aeiouy]([^aeiouwy])$/
    md ? md[1] : ''
  end
end
