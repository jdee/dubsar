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

describe Hash, "#search_options extension" do
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

describe Word do
  fixtures :words, :synsets, :senses, :inflections

  context 'validation' do
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

  context 'parts of speech' do
    it 'accepts all valid parts of speech' do
      %w{adjective adverb conjunction interjection noun preposition pronoun verb}.each do |part_of_speech|
        words(part_of_speech).should be_valid
      end
    end

    it 'does not accept a word with an invalid part of speech' do
      words(:bad_part_of_speech).should_not be_valid
    end

    it 'recognizes words with different parts of speech as distinct' do
      well_adverb = words :adverb
      well_noun   = words :well_noun

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

  context 'general data model' do
    it 'recognizes synonyms' do
      food = words :noun
      grub = words :grub

      food.synsets.any?{|s|s.words.include?(grub)}.should be_true
    end
  end

  context 'searching' do
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
