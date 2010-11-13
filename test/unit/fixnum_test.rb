#  Dubsar Dictionary Project
#  Copyright (C) 2010 Jimmy Dee
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
require 'test_helper'

class StringTest < ActiveSupport::TestCase
  setup do
    @number = 5_652
  end

  should 'produce the usual string by default' do
    assert_equal '5652', @number.to_s
  end

  should 'produce a comma-delimited string when requested' do
    assert_equal '5,652', @number.to_s(:comma_delimited)
  end
end
