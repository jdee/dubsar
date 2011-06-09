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

module ApplicationHelper
  def thumbnail_link_tag(src, type="image/png")
    "<link rel=\"thumbnail\" href=\"#{image_path src}\" type=\"#{type}\"/>"
  end

  def thumbnail_link_tags
    thumbnail_link_tag('dubsar.png') + "\n" +
    thumbnail_link_tag('autocomplete-thumbnail.png') + "\n" +
    thumbnail_link_tag('browse-thumbnail.png') + "\n" +
    thumbnail_link_tag('tooltip-thumbnail.png') + "\n" +
    thumbnail_link_tag('view-thumbnail.png')
  end

  def tour_link_tag(name, description)
    tag = <<TAG
<a href="#{image_path(name+'.png')}" title='#{name}' id='tour-#{name}'>
  <h3>#{CGI.escapeHTML description}</h3>
  #{image_tag(name+'-thumbnail.png', :alt => name, :width => '150', :height => '100')}
</a>
TAG
  end

  def html_for_link
    s = <<EOF
<a href="http://dubsar-dictionary.com" title="Dubsar Project" target="_blank"><img src="#{asset_host}/images/dubsar-link.png" alt="Dubsar" height="20" width="88" style="vertical-align: top; border-style: none;"/></a>
EOF
  end

  def html_for_fairies_link
    s = <<EOF
<a href="#{fairies_url}" title="Austin Guardian Fairies" target="_blank"><img src="#{asset_host}/images/fairies-20x20.png" alt="AGF" height="20" width="20" style="vertical-align: top; border-style: none;"/></a>
EOF
  end

  def asset_host
    host = ActionController::Base.asset_host
    if host
      host = 'http://' + host
    else
      host = ''
    end
  end

  def fairies_url
    'http://austinguardianfairies.org'
  end

  def fairies_email
    'fairies@austinguardianfairies.org'
  end

  def theme_color
    case @theme
    when 'light'
      '#1c94c4'
    when 'dark'
      '#f58400'
    end
  end
end
