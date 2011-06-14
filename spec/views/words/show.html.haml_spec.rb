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

describe '/words/show.html.haml' do
  before :each do
    noun = Factory.create :noun
    grub = Factory.create :grub
    synset = Factory.create :food_synset
    Factory.create :sense, :word => noun, :synset => synset
    Factory.create :sense, :word => grub, :synset => synset
    synset.words.count.should == 2
    @words = [ noun ]
    @words.stub(:total_pages).and_return(1)
    @count = -1
  end

  it 'should have an #accordion div' do
    render
    rendered.should have_selector(:div, :id => 'accordion')
  end
end
