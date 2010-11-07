/*
  Dubsar Dictionary Project
  Copyright (C) 2010 Jimmy Dee

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
      $('#error').stop(true).replaceWith('<div id="error" class="ui-state-active ui-corner-all line"><span class="ui-icon ui-icon-info"></span>working...</div>');
      /* just cheat off the stylesheet and don't try to compute the offset */
      $main_div.stop().animate({ top: '24.7ex' }, 'fast');
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

    /* position the main div depending on whether the error div is
       present */
    $error_div.filter(':visible').each(function(){
      $starting_offset = $(this).position().bottom;
    });
    $main_div.css({ top: $starting_offset });

    /* fade the error div */
    $error_div.filter(':visible').delay(3000).fadeOut('slow', function(){
      $main_div.animate({ top: $header_bottom }, 1000, 'easeOutBounce');
    });

    /* simplification of a recipe from the O'Reilly jQuery Cookbook */
    if ($('span.tooltip').length) {
      $('body').append('<div id="tooltip" class="ui-widget-content ui-corner-all"><div class="ui-state-hover line"></div></div>');
      var $tt = $('#tooltip');
      $('span.tooltip').hover(function(){
        $tt.html($('div.template', this).html());
        $tt.show();
      },
      function(){
        $tt.hide();
        $tt.html('');
      }).mousemove(function(ev){
        var $hd_y = $('#header').outerHeight();
        var $ev_x = ev.pageX - $('#main').position().left;
        var $ev_y = ev.pageY - $('#main').position().top;
        var $tt_x = $tt.outerWidth();
        var $tt_y = $tt.outerHeight();
        var $bd_x = $('#main').outerWidth();
        var $bd_y = $('#main').outerHeight();
        $tt.css({
          'top': $('#main').position().top + ($ev_y + $tt_y > $bd_y ? ev.pageY - $tt_y < -$hd_y ? -$hd_y + 5 : $ev_y - $tt_y : $ev_y + 10),
          'left': $('#main').position().left = ($ev_x + $tt_x + 20 > $bd_x ? $ev_x - $tt_x - 10 : $ev_x + 15)
        });
      });

      $tt.hide();
    }
  });
})(jQuery);
