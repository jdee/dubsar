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

require 'test_helper'

class SynsetTest < ActiveSupport::TestCase
  should have_many :senses
  should validate_presence_of :definition
  should validate_presence_of :lexname

  should 'return gloss and definition separately' do
    bad = synsets(:bad)
    assert_equal bad.gloss, 'the opposite of good'
    assert_equal bad.samples.count, 2
  end

  should 'return words_except a certain word from the synset' do
    good = synsets(:good)
    assert_equal good.words.count, 2
    assert_equal good.words_except(words(:good)).count, 1
    assert_equal good.words_except(words(:good)).first, words(:sweet)
  end
end
