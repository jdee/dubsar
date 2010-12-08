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
<link rel="thumbnail" href="#{asset_host}/images/dubsar.png" type="image/png"/>
<link rel="thumbnail" href="#{asset_host}/images/dubsar.jpg" type="image/jpg"/>
<link rel="thumbnail" href="#{asset_host}/images/autocomplete-thumbnail.png" type="image/png"/>
<link rel="thumbnail" href="#{asset_host}/images/browse-thumbnail.png" type="image/png"/>
<link rel="thumbnail" href="#{asset_host}/images/tooltip-thumbnail.png" type="image/png"/>
<link rel="thumbnail" href="#{asset_host}/images/view-thumbnail.png" type="image/png"/>
EOF
  end

  def tour_link_tag(name, description)
    tag = <<TAG
<a href="#{image_path(name+'.png')}" title='#{name}' id='tour-#{name}'>
  <h3>#{CGI.escapeHTML description}</h3>
  #{image_tag(name+'-thumbnail.png', :alt => name)}
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

  def facebook_like_button(url='http://dubsar-dictionary.com')
    s = <<EOF
<fb:like href="#{url}" layout="button_count" colorscheme="light"></fb:like>
EOF
  end

  def facebook_like_box
    s = <<EOF
<fb:like-box href="http://www.facebook.com/pages/Dubsar/155561501154946" width="200" connections="0" stream="false" header="false" colorscheme="dark"></fb:like-box>
EOF
  end

  def tweet_link(url='http://dubsar-dictionary.com', text='#dubsar')
    s = <<EOF
<a href="http://twitter.com/share" class="twitter-share-button" data-url="#{url}" data-text="#{text}" data-count="none" data-via="redmenace07">Tweet</a>
EOF
  end

  def su_link(url='http://dubsar-dictionary.com')
    s = <<EOF
<script src="http://www.stumbleupon.com/hostedbadge.php?s=4&r=#{url}"></script>
EOF
  end

  def delicious_link
    s = <<EOF
<a href="http://www.delicious.com/save" onclick="window.open('http://www.delicious.com/save?v=5&noui&jump=close&url='+encodeURIComponent(location.href)+'&title='+encodeURIComponent(document.title), 'delicious','toolbar=no,width=550,height=550'); return false;">
  <img src="http://l.yimg.com/hr/img/delicious.small.gif" height="10" width="10" alt="Delicious" style="border-style: none;" />
</a>
EOF
  end

  def reddit_button(url='http://dubsar-dictionary.com')
    s = <<EOF
<a href="http://reddit.com/r/all/submit?url=#{url}"> <img src="http://www.reddit.com/static/spreddit1.gif" alt="submit to reddit" style="border-style: none;" /> </a>
EOF
  end

  def buzz_link(url='http://dubsar-dictionary.com')
    s = <<EOF
<a title="Post to Google Buzz" class="google-buzz-button" href="http://www.google.com/buzz/post" data-admin-site="true" data-button-style="normal-button" data-url="#{url}" data-imageurl="#{asset_host}/images/dubsar.png"></a>
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
