/*
  Dubsar Dictionary Project
  Copyright (C) 2010-13 Jimmy Dee

  This program is free software; you can redistribute it and/or
  modify it under the terms of the GNU General Public License
  as published by the Free Software Foundation; either version 2
  of the License, or (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program; if not, write to the Free Software
  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */
;(function($){
  $(function(){
    var $error_div = $('#error');
    var $header_div = $('#header');
    var $main_div = $('#main');
    var $header_bottom = $header_div.outerHeight();
    var $starting_offset = $header_bottom;

    function post_info(){
      $error_div.stop(true).html('<span class="ui-icon ui-icon-info"></span>working...').addClass('ui-state-active').removeClass('ui-state-error').show();
      $main_div.stop().animate({ top: $header_bottom+$error_div.outerHeight()}, 'fast');
    }

    /* find the value currently associated with a cookie by name */
    /* (blank string if not found) */
    $.find_cookie = function(name){
      var allcookies = document.cookie;
      var pos = allcookies.indexOf(name);
      if (pos != -1) {
        var start = pos + name.length + 1;
        var end = allcookies.indexOf(';', start);
        if (end == -1) {
          end = allcookies.length;
        }
        return decodeURIComponent(allcookies.substring(start, end));
      }
      else {
        return '';
      }
    };

    $('.pagination a').addClass('search-link');

    $('.search-link').live('click', post_info);

    $('#qunit-link').hover(function(){
      $(this).removeClass('ui-state-default').addClass('ui-state-hover');
    }, function(){
      $(this).removeClass('ui-state-hover').addClass('ui-state-default');
    });

    /* position the main div depending on whether the error div is
       present */
    /* no more hard-coding positions, but can't leave it to CSS either */
    /* The only way to stabilize this display is to manually place
       these fixed-position elements here. */
    $error_div.css({position: 'fixed', top: $header_bottom});
    $error_div.filter(':visible').each(function(){
      $(this).css({top: $header_bottom});
      $starting_offset += $(this).outerHeight();
    });
    $main_div.css({ top: $starting_offset });

    /* fade the error div */
    $error_div.filter(':visible').delay(3000).fadeOut('slow', function(){
      $main_div.animate({ top: $header_bottom }, 1000, 'easeOutBounce');
    });
  });
})(jQuery);
