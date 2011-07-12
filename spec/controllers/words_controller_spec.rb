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

require 'json'
require 'spec_helper'

describe WordsController do
  context "handling basic routing and requests" do
    before :each do
      request.env['HTTP_REFERER'] = '/'
    end

    it "gets all defined routes" do
      %w{about faq index license link m_faq m_license mobile qunit tour}.each do |route|
        get route
        response.should be_success
      end
    end

    it "gets :search and :m_search views" do
      create_synonyms!
      %w{search m_search}.each do |route|
        get route, 'term' => 'food'
        response.should be_success
        assigns(:words).should_not be_blank
      end
    end

    it "gets :m_word view" do
      word = Factory :noun
      get :m_word, 'word_id' => word.id
      response.should be_success
      assigns(:word).should_not be_blank
      assigns(:back).should == '/'
    end

    it "gets :m_sense view" do
      food, grub = create_synonyms!
      sense = food.senses.first
      get :m_sense, 'sense_id' => sense.id, 'index' => 0
      response.should be_success
      assigns(:sense).should_not be_blank
      assigns(:index).should_not be_blank
    end

    it "ignores excess white space" do
      get :search, 'term' => '  World   War         2  '

      assigns(:term).should_not be_nil
      assigns(:term).should == 'World War 2'
    end

    it "honors case, regexp and exact :match paramters" do
      Factory :slang
      get :search, :term => 'slang', :match => 'exact'
      response.should be_success

      get :search, :term => 'slang', :match => 'case'
      response.should be_success

      get :search, :term => 'slang', :match => 'regexp'
      response.should be_success

      get :search, :term => 'slang', :match => 'foo'
      response.should be_redirect
    end

    it "uses a regexp search for letter browsing" do
      get :search, :term => 'A%'
      assigns(:match).should == 'regexp'
      assigns(:title).should == 'A'
      assigns(:term).should == '^[Aa]'
    end

    after :each do
      assigns(:theme).should_not be_nil
    end
  end

  context "handling JSON requests" do
    before :all do
      Word.delete_all
      11.times { Factory :list_entry }
    end

    before :each do
      request.env['HTTP_ACCEPT'] = 'application/json'
    end

    it 'ignores case when removing duplicates in the #os route' do
      Factory :capitalized_word
      get :os, :term => 'word'
      list = JSON.parse response.body
      list.last.should include('Word_1')
    end

    it 'ignores case when removing duplicates in the #search route' do
      Factory :capitalized_word
      get :search, :term => 'word%', :limit => 10, :offset => 0
      list = JSON.parse(response.body)['list']
      list.should include('Word_1')
    end

    it 'returns at most 10 matches from the #os route' do
      get :os, :term => 'word'
      # returns [ "term", [ "term1", "term2", ... ] ]
      list = JSON.parse response.body
      list.last.count.should == 10
    end

    it 'honors the specified limit from the #search route' do
      get :search, :term => 'word%', :offset => 0, :limit => 9
      hash = JSON.parse response.body
      list = hash['list']
      list.count.should == 9
    end

    it 'honors the maximum request limit in the #search route' do
      limit = WordsController.max_json_limit
      (limit+1).times { Factory :list_entry }
      get :search, :term => 'word%', :offset => 0, :limit => limit+1
      hash = JSON.parse response.body
      hash['total'].should > limit
      hash['list'].count.should == limit
    end

    after :all do
      Word.delete_all
    end
  end
end
