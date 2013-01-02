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

describe '/shared/_mobile_form.html.haml' do
  it 'has a form' do
    render :partial => 'shared/mobile_form'
    rendered.should have_selector(:form) do |form|
      form.should have_selector(:input, :type => 'text', :name => 'term', :id => 'word-input')
      form.should have_selector(:button, :id => 'word-submit')
    end
  end

  it 'is prepopulated with the search term' do
    assign(:term, 'halo')
    render :partial => 'shared/mobile_form'
    rendered.should have_selector('input#word-input[value="halo"]')
  end

  it 'uses a placeholder tag' do
    assign(:term, 'halo')
    render :partial => 'shared/mobile_form'
    rendered.should have_selector('input#word-input[placeholder]')
  end
end
