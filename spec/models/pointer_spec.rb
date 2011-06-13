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

describe Pointer do
  fixtures :senses

  let(:no_target) { Pointer.new :target => nil, :sense => senses(:slang), :ptype => 'attribute' }
  let(:no_sense) { Pointer.new :target => senses(:grub), :sense => nil, :ptype => 'attribute' }
  let(:no_ptype) { Pointer.new :target => senses(:grub), :sense => senses(:slang), :ptype => nil }

  it 'validates presence of :target' do
    no_target.should_not be_valid
  end

  it 'validates presence of :sense' do
    no_sense.should_not be_valid
  end

  it 'validates presence of :ptype' do
    no_ptype.should_not be_valid
  end

  describe 'create_new' do
    # used when seeding the DB

    it 'creates a new pointer' do
      lambda do
        Pointer.create_new(:sense => senses(:slang), :target => senses(:grub), :ptype => 'attribute')
      end.should change(Pointer, :count).by(1)
    end

    it 'does not create a new pointer if the same entry exists' do
      Pointer.create_new(:sense => senses(:slang), :target => senses(:grub), :ptype => 'attribute')
      lambda do
        Pointer.create_new(:sense => senses(:slang), :target => senses(:grub), :ptype => 'attribute')
      end.should_not change(Pointer, :count)
    end
  end

  describe '#help_text' do
    it 'returns a description of the pointer type' do
      Pointer.help_text('attribute').should == 'general quality'
    end
  end
end
