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

describe Delimiter do
  let(:number) { 5_652 }

  it 'produces the usual string by default' do
    number.to_s.should == "5652"
  end

  it 'produces a comma-delimited string when requested' do
    number.to_s(:delimiter => ',').should == "5,652"
  end

  it 'honors other delimiters' do
    number.to_s(:delimiter => '.').should == "5.652"
  end

  it 'delimits by thousands' do
    1_234_567_890.to_s(:delimiter => ',').should == "1,234,567,890"
  end

  it 'works for strings as well as numbers' do
    '1234567890'.to_s(:delimiter => ',').should == "1,234,567,890"
  end

  it 'works for Bignums' do
    # 2^128
    bigun = 65_536 * 65_536 * 65_536 * 65_536
    bigun *= bigun
    bigun.should be_a(Bignum)

    # 2^128 ~ 3 x 10^38
    # Hence 12 delimiters + 39 digits:
    bigun.to_s(:delimiter => ',').length.should == 51
  end

  it 'works for negative numbers' do
    -1_100.to_s(:delimiter => ',').should == "-1,100"
  end

  it 'works with a plus (+) prefix' do
    '+1100'.to_s(:delimiter => ',').should == "+1,100"
  end

  it 'works with fractions' do
    12345.678.to_s(:delimiter => ',').should == "12,345.678"
  end
end
