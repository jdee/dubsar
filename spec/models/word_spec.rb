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

require 'spec_helper'

describe Hash, "with #search_options extension" do
  it 'raises an exception if no :term specified' do
    lambda do
      {}.search_options
    end.should raise_error('no search term specified')
  end

  it 'uses the :words table in wildcard searches' do
    options = { :term => '[Ss]*', :match => 'glob' }.search_options
    conditions = options[:conditions]
    conditions.first.should match /words.name GLOB :term/
    conditions.last.should be_a(Hash)
    conditions.last[:term].should == '[Ss]*'
  end

  it 'supports a limited regexp search for iPad backward compatibility' do
    options = { :term => '^[Ss]', :match => 'regexp' }.search_options
    conditions = options[:conditions]
    conditions.first.should match /words.name GLOB :term/
    conditions.last.should be_a(Hash)
    conditions.last[:term].should == '[Ss]*'
  end

  it 'uses the :inflections table in an exact search' do
    options = { :term => 'slan_', :match => 'exact' }.search_options
    conditions = options[:conditions]
    conditions.join.should match /inflections\.name =/
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
        FactoryGirl.build(part_of_speech.to_sym).should be_valid
      end
    end

    it 'does not accept a word with an invalid part of speech' do
      FactoryGirl.build(:bad_part_of_speech).should_not be_valid
    end

    it 'recognizes words with different parts of speech as distinct' do
      well_adverb = FactoryGirl.build :adverb
      well_noun   = FactoryGirl.build :well_noun

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
      food, grub = create_synonyms!
      food.synsets.any?{|s|s.words.include?(grub)}.should be true
    end
  end

  context 'in its convenience methods' do
    before :each do
      @food, grub = create_synonyms!
    end

    it 'returns the right #page_title' do
      @food.page_title.should match /#{@food.name}/
    end

    it 'returns the right #meta_description' do
      @food.meta_description.should match /Word.*#{@food.name}/
    end

    it 'returns a label for buttons' do
      @food.button_label.should == "food (n.); also foods"
    end
  end

  context 'when searching' do
    before :each do
      add_inflections(FactoryGirl.create :verb)
    end

    it 'matches literals by inflection' do
      Word.search(:term => 'followed').count.should == 1
    end

    # https://github.com/jdee/dubsar/issues/44
    it 'handles special characters without crashing' do
      skip "this fails with the build of sqlite in MacPorts by default. pending until I rebuild that or find another solution" if RUBY_PLATFORM =~ /darwin/
      count = nil
      -> { count = Word.search(:term => 'S(', :offset => 0).count }.should_not raise_error
      count.should == 0
    end

    it 'defaults to a case-insensitive search' do
      # pending "FTS and FactoryGirl may or may not be playing well together here"
      Word.search(:term => 'Followed', :offset => 0).count.should == 1
    end
  end

  context "generating a word of the day" do
    it "returns a word at random with at least the specified number of letters" do
      add_inflections(FactoryGirl.create :substance)
      word = Word.random_word(9)
      word.name.should match /^[a-z]{9}[a-z]*$/

      # the only word in the DB when this test runs
      word.name.should == 'substance'
      word.part_of_speech.should == 'noun'
    end
  end
end
