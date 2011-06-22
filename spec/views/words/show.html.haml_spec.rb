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
  let (:word) { Factory :noun }

  before :each do
    grub = Factory :grub
    synset = Factory :food_synset
    Factory :sense, :word => word, :synset => synset
    Factory :sense, :word => grub, :synset => synset, :synset_index => 2
    words = [ word ]
    words.stub(:total_pages).and_return(1)
    assign(:words, words)
    assign(:count, -1)
  end

  it 'should have a search form' do
    render :layout => 'layouts/application', :template => 'words/show.html.haml'
    rendered.should have_selector('form', :method => 'get', :action => root_path) do |form|
      form.should have_selector('input', :type => 'text')
      form.should have_selector('button', :type => 'submit')
    end
  end

  it 'should have an #accordion div' do
    word.senses.count.should == 1
    render
    rendered.should have_selector(:div, :id => 'accordion') do |div|
      div.should have_selector(:h2, :id => word.unique_name)
    end
  end
end