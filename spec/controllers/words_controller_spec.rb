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

require 'json'
require 'spec_helper'

describe WordsController do
  context "handling basic routing and requests" do
    before :each do
      request.env['HTTP_REFERER'] = '/'
    end

    it "gets all defined routes" do
      # :index is actually currently not a real route
      %w{about faq ios_faq license link m_faq m_license m_support mobile qunit tour}.each do |route|
        get route
        response.should be_success
      end
    end

    it "gets the :index view" do
      FactoryGirl.create :daily_word, :word => FactoryGirl.create(:verb)
      get :search
      response.should be_success
      assigns(:words).should be_blank
    end

    it "gets :search and :m_search views" do
      create_synonyms!
      %w{search m_search}.each do |route|
        get route, 'term' => 'food'
        response.should be_success
        assigns(:words).should_not be_blank
      end
    end

    it "gets :show and :m_show views" do
      word = FactoryGirl.create :noun
      add_inflections word
      %w{show m_show}.each do |route|
        get route, 'id' => word.id
        response.should be_success
        assigns(:word).should_not be_blank
        assigns(:back).should == '/'
      end
    end

    it "gets the :tab view" do
      word, other = create_synonyms!
      word.senses.should_not be_empty
      get :tab, 'word_id' => word.id, 'sense_id' => word.senses.first.id
      response.should be_success
      assigns(:word).should_not be_blank
      assigns(:back).should == '/'
    end

    it "gives an error when ID not found" do
      %w{show m_show}.each do |route|
        get route, 'id' => 1_000_000
        response.status.should == 404
      end
    end

    it "gives an error when the tab is not found" do
      get :tab, :word_id => 1_000_000, :sense_id => 1
      response.status.should == 404
    end

    it "ignores excess white space" do
      get :search, 'term' => '  World   War         2  '

      assigns(:term).should_not be_nil
      assigns(:term).should == 'World War 2'
    end

    it "honors glob and regexp :match parameters" do
      add_inflections(FactoryGirl.create :slang)
      get :search, :term => '[Ss]*', :match => 'glob'
      response.should be_success

      get :search, :term => '^[Ss]', :match => 'regexp'
      response.should be_success

      get :search, :term => 'slang'
      response.should be_success

      get :search, :term => 'slang', :match => 'foo'
      response.status.should == 404
    end

    it "uses a glob search for letter browsing" do
      get :search, :term => 'A%'
      assigns(:match).should == 'glob'
      assigns(:title).should == 'A'
      assigns(:term).should == '[Aa]*'
    end

    after :each do
      assigns(:theme).should_not be_nil
    end
  end

  context "handling JSON requests" do
    before :each do
      Word.delete_all
      InflectionsFt.delete_all
      Inflection.delete_all
      11.times do
        add_inflections(FactoryGirl.create :list_entry)
      end
    end

    before :each do
      request.env['HTTP_ACCEPT'] = 'application/json'
    end

    it 'ignores case when removing duplicates in the #os route' do
      # pending "FTS and FactoryGirl may or may not be playing well together here"
      InflectionsFt.count.should == 22
      add_inflections(FactoryGirl.create :capitalized_word)
      InflectionsFt.count.should == 23

      matches = InflectionsFt.where('name MATCH "word*"')
      matches.count.should == 23

      get :os, :term => 'word'
      list = JSON.parse response.body

      list.last.count.should == 10
      list.last.should include('Word_1')
    end

    it 'returns at most 10 matches from the #os route' do
      # pending "FTS and FactoryGirl may or may not be playing well together here"
      get :os, :term => 'word'
      # returns [ "term", [ "term1", "term2", ... ] ]
      list = JSON.parse response.body
      list.last.count.should == 10
    end

    it 'returns exact matches first in the #os route, regardless of frequency count' do
      # pending "FTS and FactoryGirl may or may not be playing well together here"
      add_inflections(FactoryGirl.create :w)
      get :os, :term => 'w'
      list = JSON.parse response.body
      list.last.count.should > 1
      list.last.first.should == 'w'
    end

    it 'returns data for individual words via the :show route' do
      food, grub = create_synonyms!

      get :show, :id => food.id
      response.should be_success

      # returns
      # [ id, "name", "pos", [ "inflection1", "inflection2", ... ],
      #   [ [ sense_id1, [ [ sense_id1, "synonym1" ], [ sense_id2, "synonym2" ], ... ], "gloss1" , "lexname1", "marker1", freq_cnt1 ],
      #   [ sense_id2, ... ] ], freq_cnt ]
      entry = JSON.parse(response.body)
      entry.first.should == food.id
      entry.second.should == food.name
      entry.third.should == food.pos
      entry.fourth.should == food.other_forms
      # only has one sense
      entry.fifth.should == [ [ food.senses.first.id, [ [ grub.senses.first.id, grub.name ] ], food.synsets.first.gloss, food.synsets.first.lexname, food.senses.first.marker, food.senses.first.freq_cnt, food.senses.first.synset_id ] ]
      entry[5].should == food.freq_cnt
    end

    it 'supports pagination in JSON searches' do
      # pending "FTS and FactoryGirl may or may not be playing well together here"
      20.times do
        add_inflections(FactoryGirl.create :list_entry)
      end
      # including the 11 in the before :each block
      Word.count.should == 31
      get :search, :term => 'word', :page => 2

      response.should be_success
      list = JSON.parse response.body
      list.second.count.should == 1
      list.third.should == 2
    end

    it 'returns the word of the day' do
      word = Word.first
      FactoryGirl.create :daily_word, :word => word
      get :wotd

      response.should be_success
      list = JSON.parse response.body

      # response format:
      # [ id, "name", "pos", freq_cnt, "inflection1, inflection2 ..." ]
      list.first.should == word.id
      list.second.should == word.name
      list.third.should == word.pos
      list.fourth.should == word.freq_cnt
      list.fifth.should == word.other_forms
    end

    after :all do
      Word.delete_all
    end
  end
end
