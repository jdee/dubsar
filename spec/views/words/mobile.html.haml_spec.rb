#  Dubsar Dictionary Project
#  Copyright (C) 2010-12 Jimmy Dee
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

describe '/words/mobile.html.haml' do
  before :each do
    Factory :daily_word, :word => Factory(:substance)
  end

  it 'has basic jquery mobile page structure' do
    render
    rendered.should have_selector(:div, 'data-role' => 'page') do |page|
      page.should have_selector(:div, 'data-role' => 'header')
      page.should have_selector(:div, 'data-role' => 'content')
      page.should have_selector(:div, 'data-role' => 'footer')
    end
  end
end
