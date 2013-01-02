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

describe '/words/_word.html.haml' do
  before :each do
    @word, grub = create_synonyms!
  end

  let (:verb) { Factory :verb }
  let (:verb_synset) { Factory :follow_synset }
  let (:verb_sense) { Factory :sense, :word => verb, :synset => verb_synset }
  let (:verb_frame) { Factory :verb_frame, :number => 1, :frame => 'Something ----s' }

  before :each do
    verb.senses << verb_sense

    # associate a verb frame with this sense
    verb_sense.senses_verb_frames << Factory(:senses_verb_frame, :sense => verb_sense, :verb_frame => verb_frame)

    verb_sense.save!
    verb.save!
  end

  it 'should have a .tooltip div' do
    render :partial => 'words/word', :object => @word
    rendered.should have_selector('span.tooltip')
  end

  it 'should include verb frames' do
    render :partial => 'words/word', :object => verb
    rendered.should have_selector('span.tooltip') do |span|
      span.should have_selector(:table) do |table|
        table.should have_selector(:td) do |td|
          td.should contain(verb_frame.frame)
        end
      end
    end
  end
end
