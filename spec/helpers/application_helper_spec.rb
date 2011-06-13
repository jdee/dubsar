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

describe ApplicationHelper do
  describe '#thumbnail_link_tag' do
    it 'includes an href attribute to the source' do
      helper.thumbnail_link_tag('foo.png').should match /href="#{image_path 'foo.png'}"/
    end
  end

  describe '#thumbnail_link_tags' do
    let(:tags) { helper.thumbnail_link_tags }
    it 'includes five thumbnails' do
      %w{dubsar autocomplete-thumbnail browse-thumbnail tooltip-thumbnail view-thumbnail}.each do |src|
        tags.should match /#{src}/
      end
    end
  end

  describe 'fairies helpers' do
    it 'gives the right url' do
      helper.fairies_url.should == 'http://austinguardianfairies.org'
    end

    it 'gives the right email address' do
      helper.fairies_email.should == 'fairies@austinguardianfairies.org'
    end
  end

  describe '#theme_color' do
    it 'gives the correct light color' do
      @theme = 'light'
      helper.theme_color.should == '#1c94c4'
    end

    it 'gives the correct dark color' do
      @theme = 'dark'
      helper.theme_color.should == '#f58400'
    end
  end
end
