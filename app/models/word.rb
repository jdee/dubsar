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

# A single +Word+ entry represents a word and part of speech.  For
# example, _run_ will have two separate entries as a noun and a verb.
class Word < ActiveRecord::Base
  has_and_belongs_to_many :synsets

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
