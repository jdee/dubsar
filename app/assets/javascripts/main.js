/*
  Dubsar Dictionary Project
  Copyright (C) 2010-15 Jimmy Dee

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
;(function($) {
  $(function() {
    // hide the error div after 3 seconds if it's showing
    var errorDiv = $('#error');
    if (errorDiv.is(':visible')) {
      setTimeout(function() {
        errorDiv.slideUp('slow');
      }, 3000);
    }

    $('.synonym-link').on('click', function() {
      var link = $(this);
      var target = link.attr('href').slice(1);

      $('.lexical, .semantic').hide();

      var selected = link.hasClass('selected');
      $('.synonym-link').removeClass('selected');

      if (selected) {
        $('.semantic').show();
        link.removeClass('selected');
      }
      else {
        $('.'+target).show();
        link.addClass('selected');
      }
    });

    // if we load #word_pos, treat that like a click on the appropriate link
    var fragment = location.hash;
    console.log("fragment = " + fragment);
    if (fragment) {
      var uniqueName = fragment.slice(1);
      console.log("uniqueName = " + uniqueName);
      var link = $('a[href="' + fragment + '"]');
      if (link.size() > 0) {
        $('.semantic').hide();
        link.addClass('selected');
        $('.' + uniqueName).show();
      }
    }
  });
})(jQuery);
