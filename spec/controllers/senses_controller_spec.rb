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

describe SensesController do
  before :each do
    @food, @grub = create_synonyms!
  end

  context "handling basic routing and requests" do
    before :each do
      request.env['HTTP_REFERER'] = '/'
      @sense = @food.senses.first
    end

    it "gets the :show and :m_show views" do
      %w{show m_show}.each do |route|
        get route, 'id' => @sense.id
        response.should be_success
        assigns(:sense).should_not be_blank
      end
    end

    it "gets the :tab view" do
      get :tab, 'sense_id' => @sense.id
      response.should be_success
      assigns(:sense).should_not be_blank
    end

    it "gives an error when ID not found" do
      %w{show m_show}.each do |route|
        get route, 'id' => 1_000_000
        response.status.should == 404
      end
    end

    it "gives an error when the tab is not found" do
      get :tab, :sense_id => 1_000_000
      response.status.should == 404
    end
  end

  context "handing JSON requests" do
    before :each do
      request.env['HTTP_ACCEPT'] = 'application/json'
      @good, @bad  = create_antonyms!
    end

    it "returns senses by ID using the :show view" do
      [ @food, @good ].each do |word|
        # only one sense, with only one pointer
        sense = word.senses.first
        pointer = sense.pointers.first || sense.synset.pointers.first

        target_text = case pointer.target
        when Sense
          pointer.target.word.name_and_pos
        when Synset
          pointer.target.word_list_and_pos
        end

        get :show, :id => sense.id
        response.should be_success
        # responds with
        # [ id, [ word_id, "word_name", "word_pos" ], [ synset_id, "synset gloss" ],
        #   "lexname", "marker", freq_cnt, [ [ sense_id1, "synonym1", "marker1", freq_cnt1 ], [ sense_id2, "synonym2", "marker2", freq_cnt2 ], ... ],
        #   [ "verb frame 1", "verb frame 2", ... ], [ "sample sentence 1", "sample sentence 2", ... ],
        #   [ [ "ptype1", "target_type1", target_id1, "target text", "target gloss" ], [ "ptype2", ... ], ... ] ]
        pointer_array = [ pointer.ptype, pointer.target_type.downcase, pointer.target.id,
          target_text, pointer.target.gloss ]
        if pointer.target.is_a? Sense
          pointer_array << pointer.target.synset_id
        end

        JSON.parse(response.body).should ==
          [
            sense.id,
            [ word.id, word.name, word.pos ],
            [ sense.synset.id, sense.synset.gloss ],
            sense.synset.lexname,
            sense.marker,
            sense.freq_cnt,
            sense.synset.senses_except(sense.word).map{|s|
              [
                s.id,
                s.word.name,
                s.marker,
                s.freq_cnt,
                s.synset_id
              ]
            },
            [],
            sense.synset.samples,
            [
              pointer_array
            ]
          ]
      end
    end
  end
end
