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

describe '/words/_sense.html.haml' do
  let (:word) { Factory.create :noun }
  let (:synset) { Factory.create :food_synset }
  let (:sense) { Factory.create :sense, :word => word, :synset => synset }

  before :each do
    grub = Factory.create :grub
    Factory.create :sense, :word => grub, :synset => synset, :synset_index => 2
  end

  it 'should have a .tooltip div' do
    sense.should_not be_nil
    render :partial => 'words/sense', :locals => {:sense => sense}
    rendered.should have_selector('span.tooltip')
  end
end
