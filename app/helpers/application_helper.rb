#  Dubsar Dictionary Project
#  Copyright (C) 2010-14 Jimmy Dee
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
  include ActionDispatch::Routing::UrlFor

  alias :orig_url_for :url_for

  def apk_link
    "#{asset_host}/Dubsar-1.1.2.2.apk"
  end

  def nsa_banner
    s = <<-EOF
<script type="text/javascript">
    window._idl = {};
    _idl.variant = "modal";
    (function() {
        var idl = document.createElement('script');
        idl.type = 'text/javascript';
        idl.async = true;
        idl.src = ('https:' == document.location.protocol ? 'https://' : 'http://') + 'members.internetdefenseleague.org/include/?url=' + (_idl.url || '') + '&campaign=' + (_idl.campaign || '') + '&variant=' + (_idl.variant || 'banner');
        document.getElementsByTagName('body')[0].appendChild(idl);
    })();
</script>
    EOF
  end

  def canonical_link_tag(object=nil)
    # haml_tag :link, :rel => 'canonical', :href => canonical_url(object)
    <<-HTML
    <link rel="canonical" href="#{canonical_url(object)}" />
    HTML
  end

  def canonical_url(object=nil)
    url = "https://dubsar-dictionary.com"
    if object
      url += url_for object
    else
      url += url_for :controller => :words, :action => :search, :term => @term
      url += "&match=#{@match}" unless @match.blank?
      url += "&title=#{URI.encode @title}" unless @title.blank?
      url += "&page=#{params[:page]}" unless params[:page].blank? or params[:page].to_i == 1
      url
    end
  end

  def thumbnail_link_tag(src, type="image/png")
    "<link rel=\"thumbnail\" type=\"#{type}\" href=\"#{image_path src}\" />"
  end

  def thumbnail_link_tags
    thumbnail_link_tag('dubsar-banner.png') + "\n" +
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
  #{image_tag(name+'.png', :alt => name, :width => '134', :height => '109')}
</a>
TAG
  end

  def html_for_link
    s = <<EOF
<a href="https://dubsar-dictionary.com" title="Dubsar Project" target="_blank"><img src="#{asset_host}/images/dubsar-link.png" alt="Dubsar" height="20" width="88" style="vertical-align: top; border-style: none;"/></a>
EOF
  end

  def asset_host
    return ActionController::Base.asset_host || ''
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
<div id="fb-root"></div>
<script>
  window.fbAsyncInit = function() {
    FB.init({appId: '222997521073042', status: true, cookie: true,
             xfbml: true});
  };
  (function() {
    var e = document.createElement('script'); e.async = true;
    e.src = document.location.protocol +
      '//connect.facebook.net/en_US/all.js';
    document.getElementById('fb-root').appendChild(e);
  }());
</script>
<fb:like send="false" layout="button_count" width="150" show_faces="false" font="" colorscheme="#{@theme}"></fb:like>
    HTML
  end

  def google_button
    <<-HTML
<script type="text/javascript" src="https://apis.google.com/js/plusone.js"></script>
<g:plusone size="medium"></g:plusone>
    HTML
  end

  def twitter_button
    <<-HTML
<script src="https://platform.twitter.com/widgets.js" type="text/javascript"></script>
<div>
  <a href="https://twitter.com/share?via=dubsar&text=Dubsar%20Dictionary%20Project%20#dubsar" class="twitter-share-button">Tweet</a>
</div>
    HTML
  end

  def dubsar_button
    <<-HTML
<a href="#{link_path}" class="unstyled"><h3>or link to &nbsp;<img alt="Dubsar" height="20" width="88" src="#{image_path 'dubsar-link.png'}" style="vertical-align: bottom; border-style: none;" /></h3></a>
    HTML
  end

  def url_for(params)
    case params
    when Hash
      params.merge! protocol: 'https' if Rails.env == 'backup' || Rails.env == 'production'
    end
    orig_url_for params
  end
end
