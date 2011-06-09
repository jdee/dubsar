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

describe Synset do
  let(:no_definition) { Synset.new :definition => nil, :lexname => 'Noun.tops' }
  let(:no_lexname) { Synset.new :definition => 'a conundrum', :lexname => nil }

  fixtures :synsets, :words

  it 'validates presence of :definition' do
    no_definition.should_not be_valid
  end

  it 'validates presence of :lexname' do
    no_lexname.should_not be_valid
  end

  it 'returns gloss and definition separately' do
    bad = synsets(:bad)
    bad.gloss.should == 'the opposite of good'
    bad.samples.count.should == 2
  end

  it 'returns words_except a certain word from the synset' do
    good = synsets(:good)
    good.words.count.should == 2
    good.words_except(words(:good)).count.should == 1
    good.words_except(words(:good)).first.should == words(:sweet)
  end
end
