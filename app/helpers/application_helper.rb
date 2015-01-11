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

  def common_css
    s = <<-EOF
<style>

body {
  max-width: 750pt;
  margin-left: auto;
  margin-right: auto;
}

#dubsar-banner {
  margin: 0.5em;
}

#powered-by-wordnet {
  font-size: x-large;
  font-weight: bold;
}

* {
  font-family: Avenir Next, Verdana, Arial, sans-serif;
  font-size: xx-large;
  text-align: center;
}

hr.divider {
  height: 5px;
}

#search-form {
  margin: 0 auto;
  padding: 10px;
  width: 100%;
  /* max-width: 320pt; */
}

#search-term {
  max-width: 280pt;
  width: 87.5%;
  -webkit-appearance: none;
}

#search-field-div {
  width: 87.5%;
  max-width: 280pt;
  margin: auto;
}

#search-results #search-term {
  font-size: x-large;
}

#autocomplete-results {
  position: absolute;
  width: 87.5%;
  max-width: 280pt;
  display: none;
}

#footer, #footer *, .alphabet-link {
  font-size: small;
}

.alphabet-link {
  font-weight: bold;
}

#home-button {
  text-decoration: none;
  float: left;  
  margin: 4px;
}

.info-button {
  margin-top: 14px;
  margin-right: 14px;
  float: right;
}

a.info-link {
  text-decoration: none;
}

.template {
  display: none;
}

#error {
  border-radius: 5px;
  -moz-border-radius: 5px;
}

/* by default, lexical things are hidden. semantic things (like the total 
   frequency count for a synset) are not. */
.lexical {
  display: none;
  border-radius: 5px;
  -moz-border-radius: 5px;
  margin-top: 5px;
}

.synonym-link, .lexical {
  padding: 2px;
}

.synonym-link.selected {
  border-radius: 5px;
  -moz-border-radius: 5px;
}

.word-links {
  display: inline-block;
}

.content * {
  font-size: x-large;
}

#synset_head img.info-button {
  margin: 1px;
  display: inline;
  float: none;
}

#device_counts {
  border-spacing: 32px;
}

#main-news #news-content {
  display: none;
}

#news-headline, #news-headline *, #news-content, #news-content *,
#about, #about * {
  font-size: x-large;
}

#resume, #resume * {
  font-size: large;
}

.rounded-block {
  border-radius: 15px;
  -moz-border-radius: 15px;
  border-style: solid;
  margin: 0.5em;
  padding: 0.5em;
}

#news-headline, #news-content {
  margin-top: 2em;
  margin-bottom: 2em;
}

.radio {
  display: inline-block;
}

.radio input {
  margin: 20px;
}

</style>
    EOF
  end

  def common_light_css
    s = <<-EOF
<style>

body.style-light {
  background-color: #e0e0ff;
  color: #1c94c4;
}

body.style-light a:link {
  color: #1c94c4;
}

body.style-light a:visited {
  color: #333;
}

body.style-light a:hover,active {
  color: #fbc90b;
}

body.style-light hr.divider {
  background-color: #fbc90b;
}

body.style-light #autocomplete-results {
  background-color: white;
}

body.style-light span.autocomplete-result.selected, body.style-light span.autocomplete-result:hover {
  background-color: #87ceeb;
}

body.style-light #error.notice {
  background-color: #87ceeb;
  color: black;
}

body.style-light .lexical {
  background-color: #87ceeb;
  color: black;
}

body.style-light .synonym-link.selected {
  background-color: #87ceeb;
}

body.style-light .synonym-link:visited {
  color: #1c94c4;
}

body.style-light #amazon-dark {
  display: none;
}

body.style-light #search-form {
  color: black;
  background-color: #1c94c4;
}

body.style-light .rounded-block {
  border-color: #1c94c4;
}

</style>
    EOF
  end

  def common_dark_css
    s = <<-EOF
<style>

body.style-dark {
  background-color: black;
  color: white;
}

body.style-dark a:link {
  color: #ffd700;
}

body.style-dark a:visited {
  color: #aaa;
}

body.style-dark a:hover,active {
  color: white;
}

body.style-dark hr.divider {
  background-color: #4682b4;
}

body.style-dark #autocomplete-results {
  background-color: #333;
}

body.style-dark span.autocomplete-result.selected, body.style-dark span.autocomplete-result:hover {
  background-color: #eedd82;
}

body.style-dark span.autocomplete-result:hover a:link {
  color: #333;
}

body.style-dark span.autocomplete-result:hover a:hover {
  color: white;
}

body.style-dark #error.error {
  background-color: #eedd82;
  color: #ff4500;
}

body.style-dark #error.notice {
  background-color: #888;
  color: #ffd700;
}

body.style-dark .lexical {
  background-color: #b8860b;
}

body.style-dark .synonym-link.selected {
  background-color: #b8860b;
}

body.style-dark .synonym-link:visited {
  color: #ffd700;
}

body.style-dark #amazon-light { 
  display: none;
}

body.style-dark #search-form {
  color: black;
  background-color: #eedd82;
}

body.style-dark .rounded-block {
  border-color: #eedd82;
}

</style>
    EOF
  end

  def accordion_css
    s = <<-EOF
<style>

.accordion-head, .accordion-head *, .accordion-body, .accordion-body * {
  font-size: large;
}

.accordion-head {
  border-style: solid;
  border-width: 1px;
  border-radius: 5px;
  -moz-border-radius: 5px;

  margin-top: 5px;
  min-height: 72px;
  cursor: pointer;
}

.accordion-head.open {
  border-radius: 5px 5px 0 0;
  -moz-border-radius: 5px 5px 0 0;
}

.accordion-body {
  overflow: hidden;

  margin-left: 0;
  margin-right: 0;

  border-style: none solid solid solid;
  border-width: 1px;
  border-radius: 0 0 5px 5px;
  -moz-border-radius: 0 0 5px 5px;
}

.accordion.limited .accordion-body.open {
  max-height: 250pt;
}

</style>
    EOF
  end

  def accordion_dark_css
    s = <<-EOF
<style>

body.style-dark .accordion-head {
  border-color: #ffd700;
}

body.style-dark .accordion-head:hover, body.style-dark .accordion-head.open {
  background-color: #eedd82;
  color: black; 
  border-color: white;
} 

body.style-dark .accordion-body {
  background-color: black;
  border-color: white;
}

body.style-dark div.accordion-body table.word-links a.synonym-link:link,
body.style-dark div.accordion-body table.word-links a.synonym-link:visited,
body.style-dark div.accordion-body table.word-links a.synonym-link:hover,
body.style-dark div.accordion-body table.word-links a.synonym-link:active {
  color: white;
}

</style>
    EOF
  end

  def accordion_light_css
    s = <<-EOF
<style>

body.style-light .accordion-head {
  border-color: #1c94c4;
}

body.style-light .accordion-head:hover, body.style-light .accordion-head.open {
  background-color: #87ceeb;
  color: black; 
  border-color: black;
} 

body.style-light .accordion-body {
  background-color: white;
  border-color: black;
}

body.style-light div.accordion-body table.word-links a.synonym-link:link,
body.style-light div.accordion-body table.word-links a.synonym-link:visited,
body.style-light div.accordion-body table.word-links a.synonym-link:hover,
body.style-light div.accordion-body table.word-links a.synonym-link:active {
  color: #1c94c4;
}

</style>
    EOF
  end

  def path_to_synset_with_fragment(sense)
    synset_path sense.synset, anchor: sense.unique_name
  end

  def home_page
    @term.nil?
  end

  def search_field_options
    options = {
      autocomplete: :off,
      autocapitalize: :off,
      autocorrect: :off,
      placeholder: 'search term(s)',
      id: 'search-term',
      title: 'press enter to search',
      required: true
    }
    options[:autofocus] = :autofocus if home_page
    options
  end

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
    url = "https://dubsar.info"
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
<a href="https://dubsar.info" title="Dubsar Project" target="_blank"><img src="#{asset_host}/images/dubsar-link.png" alt="Dubsar" height="20" width="88" style="vertical-align: top; border-style: none;"/></a>
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

  def facebook_sdk
    <<-HTML
<div id="fb-root"></div>
<script>(function(d, s, id) {
  var js, fjs = d.getElementsByTagName(s)[0];
  if (d.getElementById(id)) return;
  js = d.createElement(s); js.id = id;
  js.src = "//connect.facebook.net/en_US/sdk.js#xfbml=1&version=v2.0";
  fjs.parentNode.insertBefore(js, fjs);
}(document, 'script', 'facebook-jssdk'));</script>
    HTML
  end

  def facebook_follow_button
    <<-HTML
<div class="fb-follow" data-href="https://www.facebook.com/cpyn.mobi" data-colorscheme="dark" data-layout="button" data-show-faces="false"></div>
    HTML
  end

  def new_facebook_button
    <<-HTML
<div class="fb-like" data-href="https://cpyn.mobi" data-layout="button" data-action="like" data-show-faces="false" data-colorscheme="dark" data-share="true"></div>
    HTML
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

  def twitter_button(twitter_handle, url, text)
    s = <<-HTML
      <a class="twitter-share-button" href="https://twitter.com/share"
        data-url="#{url}"
        data-via="#{twitter_handle}"
        data-related="#{twitter_handle}"
        data-count="none"
        data-text="#{text}">
      Tweet
      </a>
      <script type="text/javascript">
      window.twttr=(function(d,s,id){var t,js,fjs=d.getElementsByTagName(s)[0];if(d.getElementById(id)){return}js=d.createElement(s);js.id=id;js.src="https://platform.twitter.com/widgets.js";fjs.parentNode.insertBefore(js,fjs);return window.twttr||(t={_e:[],ready:function(f){t._e.push(f)}})}(document,"script","twitter-wjs"));
      </script>
    HTML
  end

  def twitter_follow_button
    <<-HTML
      <a class="twitter-follow-button"
        href="https://twitter.com/cpyn_mobi"
        data-show-count="false"
        data-lang="en">
      Follow @cpyn_mobi
      </a>
      <script type="text/javascript">
      window.twttr = (function (d, s, id) {
        var t, js, fjs = d.getElementsByTagName(s)[0];
        if (d.getElementById(id)) return;
        js = d.createElement(s); js.id = id;
        js.src= "https://platform.twitter.com/widgets.js";
        fjs.parentNode.insertBefore(js, fjs);
        return window.twttr || (t = { _e: [], ready: function (f) { t._e.push(f) } });
      }(document, "script", "twitter-wjs"));
      </script>
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
