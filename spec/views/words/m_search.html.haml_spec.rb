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

describe '/words/m_search.html.haml' do
  before :each do
    food, grub = create_synonyms!
    @words = [ food, grub ]
    @words.stub(:total_pages).and_return(1)
  end

  it 'has basic jquery mobile page structure' do
    render
    rendered.should have_selector(:div, 'data-role' => 'page') do |page|
      page.should have_selector(:div, 'data-role' => 'header')
      page.should have_selector(:div, 'data-role' => 'content')
      page.should have_selector(:div, 'data-role' => 'footer')
    end
  end

  it 'lists all words' do
    render
    rendered.should have_selector(:ul, 'data-role' => 'listview') do |ul|
      ul.should have_selector(:a, :href => url_for(:action => :m_word, :word_id => @words.first.id), 'data-transition' => 'slideup')
      ul.should have_selector(:a, :href => url_for(:action => :m_word, :word_id => @words.last.id), 'data-transition' => 'slideup')
    end
  end

  it 'indicates when no results are found' do
    assign(:words, [])
    render
    rendered.should contain("no results")
  end
end
