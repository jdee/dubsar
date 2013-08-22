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

describe SensesHelper do
  describe '#target_link' do
    it 'renders an appropriate link' do
      food, grub = create_synonyms!
      # target is this Synset ([food, grub])
      target = food.senses.first.synset
      link_html = helper.target_link target
      link = Nokogiri::HTML link_html

      link.text.should =~ /food/
      link.text.should_not =~ /synsets/

      link.css('a').first.attr('href').should =~ /synsets/
    end
  end

  describe '#m_target_link' do
    it 'renders an appropriate link' do
      food, grub = create_synonyms!
      # target is this Synset ([food, grub])
      target = food.senses.first.synset
      link_html = helper.m_target_link target
      link = Nokogiri::HTML link_html

      link.text.should =~ /food/
      link.text.should_not =~ /synsets/

      link.css('a').first.attr('href').should =~ /synsets/
    end
  end
end
