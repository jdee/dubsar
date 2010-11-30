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
module ApplicationHelper
  def thumbnail_link_tags
    "<link rel='thumbnail' href='#{asset_host}/images/dubsar.png' type='image/png'/><link rel='thumbnail' href='#{asset_host}/images/dubsar-link.png' type='image/png'/>"
  end

  def tour_link_tag(name, description)
    tag = <<TAG
<a href='#{asset_host}/images/#{name}.png' title='#{name}' id='tour-#{name}'>
  <h3>#{CGI.escapeHTML description}</h3>
  <img src='#{asset_host}/images/#{name}-thumbnail.png' alt='#{name}'/>
</a>
TAG
  end

  def asset_host
    host = ActionController::Base.asset_host
    if host
      host = 'http://' + host
    else
      host = ''
    end
  end
end
