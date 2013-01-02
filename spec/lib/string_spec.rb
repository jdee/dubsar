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

require 'string'
require 'spec_helper'

describe String, "with case extensions" do
  it 'should respond_to new methods' do
    'foo'.should respond_to(:upcase?)
    'bar'.should respond_to(:capitalized?)
  end

  it 'detects all-uppercase words' do
    'ABC'.should be_upcase
    'Abc'.should_not be_upcase
  end

  it 'detects capitalized words' do
    'ABC'.should be_capitalized
    'Abc'.should be_capitalized
    'aBc'.should_not be_capitalized
  end
end
