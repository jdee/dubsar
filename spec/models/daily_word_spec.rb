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

describe DailyWord do
  let(:no_word) { DailyWord.new :word => nil }

  it 'validates presence of :word' do
    no_word.should_not be_valid
  end

  it 'returns the most recent entry' do
    Factory :daily_word, :word => Factory(:substance)
    Factory :daily_word, :word => Factory(:verb)

    DailyWord.word_of_the_day.name.should == 'follow'
  end

  it 'returns nil if no wotd present' do
    DailyWord.word_of_the_day.should be_nil
  end
end
