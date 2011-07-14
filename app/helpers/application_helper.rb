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
  def canonical_link_tag(object=nil)
    url = "http://dubsar-dictionary.com"
    if object
      url += url_for object
    else
      url += url_for :action => :search, :term => @term
      url += "&match=#{@match}" unless @match.blank?
      url += "&title=#{URI.encode @title}" unless @title.blank?
      url += "&page=#{params[:page]}" unless params[:page].blank? or params[:page].to_i == 1
    end

    haml_tag :link, :rel => 'canonical', :href => url
  end

  def thumbnail_link_tag(src, type="image/png")
    "<link rel=\"thumbnail\" type=\"#{type}\" href=\"#{image_path src}\" />"
  end

  def thumbnail_link_tags
    thumbnail_link_tag('dubsar.png') + "\n" +
    thumbnail_link_tag('autocomplete.png') + "\n" +
    thumbnail_link_tag('browse.png') + "\n" +
    thumbnail_link_tag('tooltip.png') + "\n" +
    thumbnail_link_tag('view.png') + "\n" +
    thumbnail_link_tag('sense.png') + "\n" +
    thumbnail_link_tag('synset.png')
  end

  def tour_link_tag(name, description)
    tag = <<TAG
<a href="#{image_path(name+'.png')}" title='#{name}' id='tour-#{name}'>
  <h3>#{CGI.escapeHTML description}</h3>
  #{image_tag(name+'.png', :alt => name, :width => '157', :height => '100')}
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

  def facebook_button
    <<-HTML
<iframe src="http://www.facebook.com/plugins/like.php?app_id=222997521073042&amp;href=http%3A%2F%2Fdubsar-dictionary.com&amp;send=false&amp;layout=button_count&amp;width=150&amp;show_faces=false&amp;action=like&amp;colorscheme=#{@theme}&amp;font&amp;height=21" scrolling="no" frameborder="0" style="border:none; overflow:hidden; width:150px; height:21px;" allowTransparency="true"></iframe>
    HTML
  end

  def google_button
    <<-HTML
<script type="text/javascript" src="https://apis.google.com/js/plusone.js"></script>
<g:plusone size="medium" href="http://dubsar-dictionary.com"></g:plusone>
    HTML
  end

  def twitter_button
    <<-HTML
<script src="http://platform.twitter.com/widgets.js" type="text/javascript"></script>
<div>
  <a href="http://twitter.com/share?url=http%3A%2F%2Fdubsar-dictionary.com&via=dubsar&text=Dubsar%20Dictionary%20Project%20#dubsar" class="twitter-share-button">Tweet</a>
</div>
    HTML
  end

  def dubsar_button
    <<-HTML
<a href="#{link_path}" class="unstyled"><h3>or link to &nbsp;<img alt="Dubsar" height="20" width="88" src="#{image_path 'dubsar-link.png'}" style="vertical-align: bottom; border-style: none;" /></h3></a>
    HTML
  end
end
