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

require 'spec_helper'

describe Hash, "with #search_options extension" do
  it 'raises an exception if no :term specified' do
    lambda do
      {}.search_options
    end.should raise_error('no search term specified')
  end

  it 'uses the :words table in wildcard searches' do
    options = { :term => 'slan_', :match => 'case' }.search_options
    conditions = options[:conditions]
    conditions.join.should match /words\.name LIKE/

    options = { :term => 'slan.', :match => 'regexp' }.search_options
    conditions = options[:conditions]
    conditions.join.should match /words\.name ~/
  end

  it 'uses the :inflections table in an exact search' do
    options = { :term => 'slan_', :match => 'exact' }.search_options
    conditions = options[:conditions]
    conditions.join.should match /inflections\.name =/
  end
end

describe String, "with #double_consonant? extension" do
  it 'returns false for mortar' do
    'mortar'.should_not be_a_double_consonant
  end

  it 'returns true for certain verbs ending in L, N or R' do
    'gel'.should be_a_double_consonant
    'grin'.should be_a_double_consonant
    'spur'.should be_a_double_consonant
  end

  it 'returns true for verbs ending in -CVt' do
    'fit'.should be_a_double_consonant
  end

  it 'returns false for certain verbs ending in -CVt' do
    'exit'.should_not be_a_double_consonant
  end

  it 'returns false otherwise' do
    'cry'.should_not be_a_double_consonant
  end
end

describe Word do
  context 'when validating' do
    let(:no_name) { Word.new :name => nil, :part_of_speech => 'noun', :freq_cnt => 10 }
    let(:no_part_of_speech) { Word.new :name => 'pass', :part_of_speech => nil, :freq_cnt => 10 }
    let(:no_freq_cnt) { Word.new :name => 'pass', :part_of_speech => 'noun', :freq_cnt => nil }

    it 'validates presence of :name' do
      no_name.should_not be_valid
    end

    it 'validates presence of :part_of_speech' do
      no_part_of_speech.should_not be_valid
    end

    it 'validates presence of :freq_cnt' do
      no_freq_cnt.should_not be_valid
    end
  end

  context 'when handling parts of speech' do
    it 'accepts all valid parts of speech' do
      %w{adjective adverb conjunction interjection noun preposition pronoun verb}.each do |part_of_speech|
        Factory(part_of_speech.to_sym).should be_valid
      end
    end

    it 'does not accept a word with an invalid part of speech' do
      Factory(:bad_part_of_speech).should_not be_valid
    end

    it 'recognizes words with different parts of speech as distinct' do
      well_adverb = Factory :adverb
      well_noun   = Factory :well_noun

      well_adverb.should be_valid
      well_noun.should be_valid

      well_adverb.name.should == well_noun.name
      well_adverb.part_of_speech.should_not == well_noun.part_of_speech
      well_adverb.should_not == well_noun
    end

    it 'maps parts of speech to abbreviated names' do
      {
        'adjective'    => 'adj'   ,
        'adverb'       => 'adv'   ,
        'conjunction'  => 'conj'  ,
        'interjection' => 'interj',
        'noun'         => 'n'     ,
        'preposition'  => 'prep'  ,
        'pronoun'      => 'pron'  ,
        'verb'         => 'v'
      }.each do |name, abbr|
        Word.pos(name).should == abbr.to_sym
      end
    end
  end

  context 'in the general data model' do
    it 'recognizes synonyms' do
      food_synset = Factory.create :food_synset
      food = Factory :noun
      grub = Factory :grub

      food.senses << Factory(:sense, :synset => food_synset)
      grub.senses << Factory(:sense, :synset => food_synset, :synset_index => 2)
      food.save!
      grub.save!

      food.synsets.any?{|s|s.words.include?(grub)}.should be_true
    end
  end

  context 'when searching' do
    before :each do
      Factory.create :verb
    end

    it 'matches literals by inflection' do
      Word.search(:term => 'followed', :offset => 0).count.should == 1
    end

    it 'does not match inflections in wild-card searches' do
      Word.search(:term => 'followe_', :offset => 0).count.should == 0
      Word.search(:term => 'follo_', :offset => 0).count.should == 1
    end

    it 'defaults to a case-insensitive search' do
      Word.search(:term => 'Followed', :offset => 0).count.should == 1
    end

    it 'honors a case-sensitive search' do
      Word.search(:term => 'followed', :match => 'case', :offset => 0).count.should == 1
      Word.search(:term => 'Followed', :match => 'case', :offset => 0).count.should == 0
    end
  end
end
