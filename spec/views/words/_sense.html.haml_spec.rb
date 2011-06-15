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
  let (:word) { Factory :noun }
  let (:synset) { Factory :food_synset }
  let (:sense) { Factory :sense, :word => word, :synset => synset }

  before :each do
    # define 'grub' as a synonym for word (food)
    grub = Factory :grub
    Factory :sense, :word => grub, :synset => synset, :synset_index => 2

    # define 'substance' as a hypernym for word
    substance = Factory :substance
    substance_sense = Factory :sense, :word => substance, :synset => Factory(:substance_synset)
    Factory :pointer, :sense => sense, :target => substance_sense, :ptype => 'hypernym'
  end

  let (:verb) { Factory :verb }
  let (:verb_synset) { Factory :follow_synset }
  let (:verb_sense) { Factory :sense, :word => verb, :synset => verb_synset }
  let (:verb_frame) { Factory :verb_frame, :number => 1, :frame => 'Something ----s' }

  before :each do
    # associate a verb frame with this sense
    Factory :senses_verb_frame, :sense => verb_sense, :verb_frame => verb_frame
  end

  it 'should have a .tooltip div' do
    sense.should_not be_nil
    render :partial => 'words/sense', :locals => { :sense => sense }
    rendered.should have_selector('span.tooltip')
  end

  it 'should include verb frames' do
    verb_sense.should_not be_nil
    render :partial => 'words/sense', :locals => { :sense => verb_sense }
    rendered.should have_selector('span.tooltip') do |span|
      span.should have_selector(:table) do |table|
        table.should have_selector(:td) do |td|
          td.should contain(verb_frame.frame)
        end
      end
    end
  end
end
