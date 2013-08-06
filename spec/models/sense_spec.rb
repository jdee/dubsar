#  Dubsar Dictionary Project
#  Copyright (C) 2010-13 Jimmy Dee
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

describe Sense do
  let(:sense) { FactoryGirl.create :sense, :synset => FactoryGirl.create(:food_synset), :word => FactoryGirl.create(:noun) }

  context 'when validating' do
    let(:no_freq_cnt) { Sense.new :freq_cnt => nil, :synset_index => 1 }
    let(:no_synset_index) { Sense.new :freq_cnt => 10, :synset_index => nil }

    it 'validates presence of :freq_cnt' do
      no_freq_cnt.should_not be_valid
    end

    it 'validates presence of :synset_index' do
      no_synset_index.should_not be_valid
    end
  end

  context 'in the general data model' do
    it 'returns its word in an array as :words' do
      sense.words.should == [ sense.word ]
    end
  end

  context 'in its convenience methods' do
    it 'returns the right #page_title' do
      sense.page_title.should match /#{sense.word.name}/
    end

    it 'returns the right #meta_description' do
      sense.meta_description.should match /Sense.* #{sense.word.name}.*#{sense.synset.gloss}/
    end
  end
end
