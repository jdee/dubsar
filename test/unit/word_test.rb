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

require 'test_helper'

class WordTest < ActiveSupport::TestCase
  should validate_presence_of :name
  should validate_presence_of :part_of_speech
  should validate_presence_of :freq_cnt
  should have_many :senses
  should have_many :inflections

  should 'accept a valid adjective' do
    assert_valid words(:noun)
  end

  should 'accept a valid adverb' do
    assert_valid words(:adverb)
  end

  should 'accept a valid conjunction' do
    assert_valid words(:conjunction)
  end

  should 'accept a valid interjection' do
    assert_valid words(:interjection)
  end

  should 'accept a valid noun' do
    assert_valid words(:noun)
  end

  should 'accept a valid preposition' do
    assert_valid words(:preposition)
  end

  should 'accept a valid pronoun' do
    assert_valid words(:pronoun)
  end

  should 'accept a valid verb' do
    assert_valid words(:verb)
  end

  should 'not accept a word with an invalid part of speech' do
    w = words(:bad_part_of_speech)
    assert !w.valid?
  end

  should 'recognize words with different parts of speech as distinct' do
    well_adverb = words :adverb
    well_noun   = words :well_noun

    assert_valid well_adverb
    assert_valid well_noun

    assert_equal well_adverb.name, well_noun.name
    assert_not_equal well_adverb.part_of_speech, well_noun.part_of_speech
    assert_not_equal well_adverb, well_noun
  end

  should 'recognize synonyms' do
    food = words :noun
    grub = words :grub

    assert food.synsets.any? { |s| s.words.include? grub }
  end

  should 'match literals by inflection' do
    words = Word.search :term => 'followed', :offset => 0
    assert_equal 1, words.count
  end

  should 'not match inflections in wild-card searches' do
    words = Word.search :term => 'followe_', :offset => 0
    assert_equal 0, words.count

    words = Word.search :term => 'follo_', :offset => 0
  end

  should 'default to a case-insensitive search' do
    words = Word.search :term => 'Followed', :offset => 0
    assert_equal 1, words.count
  end

  should 'honor a case-sensitive search' do
    words = Word.search :term => 'followed', :match => 'case', :offset => 0
    assert_equal 1, words.count

    words = Word.search :term => 'Followed', :match => 'case', :offset => 0
    assert_equal 0, words.count
  end

  should 'find a cluster adjective as a literal' do
    words = Word.search :term => 'well(p)', :offset => 0
    assert_equal 1, words.count

    words = Word.search :term => 'well(p)', :match => 'case', :offset => 0
    assert_equal 1, words.count
  end

end
