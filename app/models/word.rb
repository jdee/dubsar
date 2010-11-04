#  Dubsar Dictionary Project
#  Copyright (C) 2010 Jimmy Dee
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
    operator = case copy.delete(:match)
    when nil, ''
      table = :words if /[%_]/ =~ copy[:term]
      'ILIKE'
    when 'case'
      table = :words if /[%_]/ =~ copy[:term]
      'LIKE'
    when 'regexp'
      table = :words
      '~'
    when 'exact'
      '='
    end

    case table
    when :inflections
      copy.merge!(
        :conditions => [ "inflections.name #{operator} ?", copy.delete(:term) ],
        :joins => 'INNER JOIN inflections ON words.id = inflections.word_id')
    when :words
      copy.merge! :conditions => [ "name #{operator} ?", copy.delete(:term) ]
    end
    copy.merge!(:page => copy[:page]) if copy.has_key?(:page)
    copy.symbolize_keys
  end

  def clone_without_controller_params
    copy = clone
    copy.delete(:action)
    copy.delete(:back)
    copy.delete(:controller)
    copy.delete(:format)
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
    else
      false
    end
  end
end

# A single +Word+ entry represents a word and part of speech.  For
# example, _run_ will have two separate entries as a noun and a verb.
class Word < ActiveRecord::Base
  before_save :compute_freq_cnt
  has_many :senses, :order => 'freq_cnt DESC'
  has_many :synsets, :through => :senses, :order => 'senses.freq_cnt DESC'
  has_many :inflections

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

  # Abbreviation for the full part_of_speech
  def pos
    sym = self.class.pos(part_of_speech)
    sym ? sym.to_s : ''
  end

  # generates an identifier (no spaces) from the word's name and
  # part of speech
  def unique_name
    (name.capitalized? ? 'cap-' : '') +
      "#{name.downcase.gsub(/[\s.']/, '_')}_#{pos}"
  end

  def create_new_inflection(name)
    inflections.create(:name => name) if inflections.find_by_name(name).nil?
  end

  def build_new_inflection(name)
    inflections.build(:name => name) if inflections.find_by_name(name).nil?
  end

  def add_regular_inflections
    # DEBT: Should subclass and have this handled polymorphically,
    # but for now there's not much here.

    # Only attempt regular inflection of single words for now.
    if name =~ /^[^ ]+$/
      if inflections.empty?
        method = "add_regular_#{part_of_speech}_inflections"
        self.send method
      elsif part_of_speech == 'verb'
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
    # Takes a has of options:
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
  end

  def remove_duplicate_inflections
    inflections.each do |i|
      inflections.delete(i) if
        inflections.count(:all, :conditions => [ "name = ?",  i.name ]) > 1
    end
  end

  def compute_freq_cnt
    self.freq_cnt = senses.sum :freq_cnt
  end

  private

  def add_regular_adjective_inflections
    # These end up looking absurd much of the time
  end

  def add_regular_adverb_inflections
    # There are no regular adverb inflections
  end

  def add_regular_noun_inflections
    # Use the active_support inflector for regular nouns.
    inflections.build :name => name.pluralize
  end

  def add_regular_verb_inflections
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
    return unless inflections.find(:all, :conditions => "name ~ '[ny]ing$'").empty?

    case name
    when /^.e$/
      # pretty much just being, but would also produce things like meing
      build_new_inflection name + 'ing'
    when /[^e]e$/
      build_new_inflection name.sub(/e$/, 'ing')
    when /[^aeiou][aeiouy][lnr]$/
      c = /[^aeiou][aeiouy]([lnr])$/.match(name)[1]
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
    when /y$/
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
    when /y$/
      build_new_inflection name.sub(/y$/, 'ied')
    when /[^aeiou][aeiouy][lnr]$/
      c = /[^aeiou][aeiouy]([lnr])$/.match(name)[1]
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
    md = name.match /[^aeiou][aeiouy]([^aeiouy])$/
    md ? md[1] : ''
  end
end
