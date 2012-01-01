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

describe Fairy do
  let(:no_name) { Fairy.new :name => nil, :email => 'user@example.com' }
  let(:no_email) { Fairy.new :name => 'Fairy Nuff', :email => nil }

  it 'validates presence of :name' do
    no_name.should_not be_valid
  end

  it 'validates presence of :email' do
    no_email.should_not be_valid
  end
end
