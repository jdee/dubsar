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

describe SynsetsController do
  context "handling basic routing and requests" do
    before :each do
      request.env['HTTP_REFERER'] = '/'
    end

    it "gets the :show and :m_show views" do
      food, grub = create_synonyms!
      %w{show m_show}.each do |route|
        get route, 'id' => food.synsets.first.id
        response.should be_success
        assigns(:synset).should_not be_blank
      end
    end

    it "gets the :tab view" do
      food, grub = create_synonyms!
      sense = food.senses.first
      synset = sense.synset
      get :tab, 'synset_id' => synset.id, 'sense_id' => sense.id
      response.should be_success
      assigns(:synset).should_not be_blank
    end

    it "gives an error when ID not found" do
      %w{show m_show}.each do |route|
        get route, 'id' => 1_000_000
        response.status.should == 404
      end
    end

    it "gives an error when the tab is not found" do
      get :tab, :synset_id => 1_000_000, :sense_id => 1
      response.status.should == 404
    end
  end

  context "handing JSON requests" do
    before :each do
      request.env['HTTP_ACCEPT'] = 'application/json'
      @food, @grub = create_synonyms!
    end

    it "returns senses by ID using the :show view" do
      good, bad = create_antonyms!
      synset = good.synsets.first
      get :show, :id => synset.id
      response.should be_success
      # Responds with
      #   [ id, "pos", "lexname", "gloss", [ "sample sentence 1", "sample sentence 2", ... ],
      #     [ [ sense_id1, "synonym1", "marker1", freq_cnt1 ], [ sense_id2, "synonym2", "marker2", freq_cnt2 ] ], freq_cnt,
      #     [ [ "ptype1", "target_type1", target_id1, "target text", "target gloss" ], [ "ptype2", ... ], ... ] ]
      JSON.parse(response.body).should ==
        [ synset.id, 'adj', synset.lexname, synset.gloss, synset.samples, synset.senses.all(:joins => "JOIN words ON words.id = senses.word_id", :order => 'words.name').map{|s|[s.id,s.word.name,s.marker,s.freq_cnt]}, synset.freq_cnt, [ [ "antonym", "synset", bad.senses.first.synset_id, bad.senses.first.synset.word_list_and_pos, bad.senses.first.synset.gloss ] ] ]
    end
  end
end
