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

    var openElement = null;

    // DEBT: This probably won't work with more than one accordion on a page.
    $('.accordion .accordion-body').each(function(n) {
      if (n == 0) {
        $(this).data('open', true);
        $(this).addClass('open').prev('.accordion-head').addClass('open');
        openElement = $(this);
      }
      else {
        $(this).data('open', false);
        $(this).hide();
      }
    });

    $('.accordion').data('openElement', openElement);

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

      // the currently open body element
      var elm = accordion.data('openElement');

      // close the currently open pane
      // hide instead of fade so that the scrollTop call below works. Otherwise, have to
      // scroll after that's hidden. or account for the change in advance.
      elm.data('open', false);
      elm.hide();
      elm.addClass('open').prev('.accordion-head').removeClass('open');

      // now open the body element for this head
      body.data('open', true);
      body.slideDown('fast');
      body.addClass('open');
      $(this).addClass('open');

      // and record the current pane on the accordion itself
      accordion.data('openElement', body);
    });
    
  });
})(jQuery);
