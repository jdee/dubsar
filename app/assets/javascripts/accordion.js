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

    $('.accordion').data('openPane', 0);

    // DEBT: This probably won't work with more than one accordion.
    $('.accordion .accordion-body').each(function(n) {
      if (n == 0) {
        $(this).data('open', true);
      }
      else {
        $(this).data('open', false);
        $(this).hide();
      }

      $(this).data('index', n);
    });

    $('.accordion .accordion-head').on('click', function() {
      // the body associated with this head
      var body = $(this).next('.accordion-body');
      // whether that is currently open
      var open = body.data('open');

      if (open) {
        // no-op
        return;
      }

      // the containing accordion
      var accordion = $(this).closest('.accordion');
      // the 0-based index of the currently open pane in that accordion
      var openPane = accordion.data('openPane');

      // nth-child is 1-based. Also, there are two children per pane--one head and one
      // body--hence the *= 2.
      ++ openPane;
      openPane *= 2;

      // the currently open body element
      var openElement = $('.accordion-body:nth-child(' + openPane + ')', accordion);

      // close the currently open pane
      // hide instead of fade so that the scrollTop call below works. Otherwise, have to
      // scroll after that's hidden. or account for the change in advance.
      openElement.hide();
      openElement.data('open', false);

      // now open the body element for this head
      body.fadeIn('fast');
      body.data('open', true);

      // and record the current pane on the accordion itself
      accordion.data('openPane', body.data('index'));

      // and scroll the new thing to the top
      $(document).scrollTop($(this).offset().top);
    });
    
  });
})(jQuery);
