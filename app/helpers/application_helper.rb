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
    s = <<EOF
<link rel="thumbnail" href="#{image_path 'dubsar.png'}" type="image/png"/>
<link rel="thumbnail" href="#{image_path 'autocomplete-thumbnail.png'}" type="image/png"/>
<link rel="thumbnail" href="#{image_path 'browse-thumbnail.png'}" type="image/png"/>
<link rel="thumbnail" href="#{image_path 'tooltip-thumbnail.png'}" type="image/png"/>
<link rel="thumbnail" href="#{image_path 'view-thumbnail.png'}" type="image/png"/>
EOF
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

  def asset_host
    host = ActionController::Base.asset_host
    if host
      host = 'http://' + host
    else
      host = ''
    end
  end

  def delicious_link(url='http://dubsar-dictionary.com', title='Dubsar')
    s = <<EOF
<span id="delicious-link">
  <img src="http://l.yimg.com/hr/img/delicious.small.gif" height="10" width="10" alt="Delicious" style="border-style: none;" />
  <a href="http://www.delicious.com/save" onclick="window.open('http://www.delicious.com/save?v=5&noui&jump=close&url='+encodeURIComponent('#{url}')+'&title='+encodeURIComponent('#{title}'), 'delicious','toolbar=no,width=550,height=550'); return false;" id="delicious-text">
    Bookmark this on Delicious
  </a>
</span>
EOF
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
