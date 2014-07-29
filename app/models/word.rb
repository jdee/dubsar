#  Dubsar Dictionary Project
#  Copyright (C) 2010-14 Jimmy Dee
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
    term = copy.delete(:term)

    params = {}

    conditions = case match
    when nil, ''
      table = :inflections_fts
      params.merge! :term => term
      "inflections_fts.name MATCH :term"
    when 'glob'
      params.merge! :term => term
      table = :words
      matches = /^\[([A-Z])([a-z])\]\*$/.match(term)
      if matches
        capital1 = matches[1]
        capital2 = '' << capital1.getbyte(0)+1
        lower1 = matches[2]
        lower2 = '' << lower1.getbyte(0)+1
      else
        capital1 = 'A'
        capital2 = '['
        lower1   = 'a'
        lower2   = '{'
      end

      params.merge!(
        :capital1 => capital1,
        :capital2 => capital2,
        :lower1   => lower1,
        :lower2   => lower2
      )

      if matches
        <<-SQL
        ((words.name >= :capital1 AND words.name < :capital2) OR
         (words.name >= :lower1 AND words.name < :lower2 )) AND
        words.name GLOB :term
        SQL
      else
        # assume this is [^A-Za-z]*
        <<-SQL
        (words.name < :capital1 OR (words.name >= :capital2 AND words.name < :lower1)
        OR words.name >= :lower2) AND words.name GLOB :term
        SQL
      end
    when 'regexp'
      # only supported for backward compatibility with the iPad 1.0.1
      # client; always expect term to be '^[character-class]'
      table = :words
      matches = /^\^\[([A-Z])([a-z])\]$/.match(term)
      if matches
        capital1 = matches[1]
        capital2 = '' << capital1.getbyte(0)+1
        lower1 = matches[2]
        lower2 = '' << lower1.getbyte(0)+1
      else
        capital1 = 'A'
        capital2 = '['
        lower1   = 'a'
        lower2   = '{'
      end

      params.merge!(
        :capital1 => capital1,
        :capital2 => capital2,
        :lower1   => lower1,
        :lower2   => lower2,
        :term     => "[#{capital1}#{lower1}]*"
      )

      if matches
        <<-SQL
        ((words.name >= :capital1 AND words.name < :capital2) OR
         (words.name >= :lower1 AND words.name < :lower2 )) AND
        words.name GLOB :term
        SQL
      else
        # assume this is [^A-Za-z]*
        <<-SQL
        (words.name < :capital1 OR (words.name >= :capital2 AND words.name < :lower1)
        OR words.name >= :lower2) AND words.name GLOB :term
        SQL
      end
    when 'exact'
      params.merge! :term => term
      "inflections.name = :term"
    end

    case table
    when :inflections_fts
      copy.merge!(
        :conditions => [ conditions, params],
        :joins => 'INNER JOIN inflections_fts ON words.id = inflections_fts.word_id')
    when :inflections
      copy.merge!(
        :conditions => [ conditions, params ],
        :joins => 'INNER JOIN inflections ON words.id = inflections.word_id')
    when :words
      copy.merge! :conditions => [ conditions, params ]
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

# A single +Word+ entry represents a word and part of speech.  For
# example, _run_ will have two separate entries as a noun and a verb.
class Word < ActiveRecord::Base
  before_save :compute_freq_cnt
  has_many :senses, -> { order('senses.freq_cnt DESC, senses.id ASC') }, dependent: :destroy
  has_many :synsets, -> { order('senses.freq_cnt DESC, senses.id ASC') }, through: :senses
  has_many :inflections, -> { order('inflections.name ASC') }, dependent: :destroy

  scope :empty, -> { includes(:senses).where(senses: { id: nil })  }

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
  end

  def before_destroy
    daily_words = DailyWord.where(word_id: id)
    return if daily_words.blank?
    puts "Removing #{daily_words.count} daily word row(s) for word ID #{id}"
    daily_words.destroy_all

    true
  rescue
    # If, I don't know, there's like no daily_words table or something, just figure
    # it must be for iOS and silently ignore it.
    true
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
    "#{name}, #{pos}."
  end

  # generates an identifier (no spaces) from the word's name and
  # part of speech
  def unique_name
    (name.capitalized? ? 'cap-' : '') +
      "#{name.downcase.gsub(/[\s.']/, '_')}_#{pos}"
  end

  def other_forms
    inflections.where([ 'name != ?', name ]).
      order('name').map{|infl|infl.name}.join(', ')
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
    # Pass any additional options to <tt>:find,</tt> particularly
    #   <tt>:limit</tt>
    # which are used in autocompletion (os) requests.
    def search(options={})
      options = options.symbolize_keys
      return nil unless options[:term]

      case options[:match]
      when 'exact'
        raise "match: 'exact' no longer supported"
      when 'glob', 'regexp'
        # Really only happens for glob and maybe regexp
        includes(options[:include]).where(options.search_options[:conditions]).paginate(page: options[:page]).order(options[:order])
      else
        # FTS search, may need to look for exact match first
        page = options[:page].nil? ? 1 : options[:page].to_i

        num_exact = Word.includes(:inflections).where(inflections: { name: options[:term] }).count

        words = nil
        if page == 1
          # exact match, then the rest
          words = Word.includes(:inflections).where(inflections: { name: options[:term] }).order('words.name ASC, words.freq_cnt DESC, words.part_of_speech ASC')
          words += Word.joins('INNER JOIN inflections_fts ON inflections_fts.word_id = words.id').where(['inflections_fts.name MATCH :term AND inflections_fts.name != :term', { :term => options[:term] }]).
            order('words.name ASC, words.part_of_speech ASC').
            limit(30 - num_exact)
        else
          words = Word.select('words.id, words.name, words.part_of_speech, words.freq_cnt').distinct.
            joins('INNER JOIN inflections_fts ON inflections_fts.word_id = words.id').
            where([ 'inflections_fts.name MATCH :term AND inflections_fts.name != :term',
              { :term => options[:term] }]).
            order('words.name ASC, words.part_of_speech ASC').
            limit(30).offset(30*(page-1) - num_exact)
        end

        def words.total_pages
          @total_pages
        end
        def words.total_pages=(total_pages)
          @total_pages = total_pages
        end

        def words.current_page
          @current_page
        end
        def words.current_page=(current_page)
          @current_page = current_page
        end

        def words.previous_page
          @previous_page
        end
        def words.previous_page=(previous_page)
          @previous_page = previous_page
        end

        def words.next_page
          @next_page
        end
        def words.next_page=(next_page)
          @next_page = next_page
        end

        total_matches = Word.select('words.id').distinct.
          joins('INNER JOIN inflections_fts ON inflections_fts.word_id = words.id').
          where(["inflections_fts.name MATCH ?", options[:term]]).count
        total = total_matches / 30
        total += 1 unless (total_matches%30).zero?
        words.total_pages = total
        words.current_page = page
        words.next_page = page + 1 if page < total
        words.previous_page = page - 1 if page > 1

        def words.per_page
          30
        end
        words
      end
    end

    # Select a Word entry from the DB at random. Must be all lowercase
    # with no spaces or punctuation, at least <tt>min_length</tt>
    # letters (9 by default).
    def random_word(min_length=9)
      pattern = ''
      min_length.times do
        pattern += '[a-z]'
      end

      words = Word.where([ "name >= 'a' AND name < '{' AND name GLOB '#{pattern}*' AND NOT name GLOB ?",
        "*[A-Z0-9 .'-]*" ]).select(:id)
      random_number = SecureRandom.random_number(words.count)
      Word.find words[random_number].id
    end
  end

  def compute_freq_cnt
    self.freq_cnt = senses.sum :freq_cnt
  end
end
