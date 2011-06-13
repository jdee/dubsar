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

describe WordsHelper do
  fixtures :words, :inflections

  describe "#search_title" do
    before :each do
      words = stub('words')
      words.stub(:total_pages).and_return(2)
      words.stub(:empty?).and_return(false)
      @words = words
      @title = 'title'
    end

    it 'includes a page number when appropriate' do
      helper.search_title.should match /\(p\. 1\)/
    end

    it 'honors the @title variable before the @term variable' do
      @term = 'term'
      helper.search_title.should match /title/
      helper.search_title.should_not match /term/
    end

    it 'appears in the page title' do
      helper.page_title.should == "Dubsar - #{helper.search_title}"
    end
  end

  describe 'spanners' do
    describe '#frame_spanner' do
      it 'spans any occurrence of the string "PP"' do
        helper.frame_spanner('PP').should match %r{<span.*>PP</span>}
      end
    end

    describe '#marker_spanner' do
      it 'spans each marker type' do
        %w{p a ip}.each do |marker|
          helper.marker_spanner(marker).should match %r{<span.*>\(#{marker}\)</span>}
        end
      end

      it 'does not span any other string' do
        helper.marker_spanner('foo').should be_blank
      end
    end
  end

  describe 'counters' do
    describe '#model_count' do
      it 'counts the number of entries for any given model' do
        helper.model_count('word').should == "15"
      end
    end

    describe '#part_of_speech_count' do
      it 'counts the part of speech for words' do
        helper.part_of_speech_count('word', 'adjective').should == 4
      end

      it 'counts the part of speech for inflections' do
        helper.part_of_speech_count('inflection', 'adjective').should == 8
      end
    end
  end

  describe '#meta_description' do
    it 'includes the title and resulting words' do
      words = [ words(:adverb) ]
      helper.meta_description('a title', words).should match /a title: well, adv\.$/
    end

    it 'includes inflections when appropriate' do
      words = [ words(:noun) ]
      helper.meta_description('food', words).should match /food: food, n\. \(foods\)$/
    end
  end
end
