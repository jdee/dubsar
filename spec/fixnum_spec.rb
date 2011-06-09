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

require 'fixnum'
require 'spec_helper'

describe Fixnum, "with comma-delimited thousands" do
  before :each do
    @number = 5_652
  end

  it 'produces the usual string by default' do
    @number.to_s.should == "5652"
  end

  it 'produces a comma-delimited string when requested' do
    @number.to_s(:comma_delimited).should == "5,652"
  end
end
