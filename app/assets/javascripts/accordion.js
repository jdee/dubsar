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
        $(this).prev('.accordion-head').addClass('open');
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

      // console.log('accordion.openPane = ' + openPane);

      // nth-child is 1-based. Also, there are two children per pane--one head and one
      // body--hence the *= 2.
      ++ openPane;
      openPane *= 2;

      // console.log('closing ' + openPane + 'th child');

      // the currently open body element
      // .accordion-body:nth-child(n) also works in many cases, but not all. not sure if
      // the semantics of nth-child vary btw Safari on OS X and iOS, but if it works this
      // way, there's no need to specify the element class or type. it's not the nth-child
      // of accordion that matches .accordion-body, it's the nth-child period.
      // Anyway, this seems to be more portable.
      var openElement = $('*:nth-child(' + openPane + ')', accordion);

      // close the currently open pane
      // hide instead of fade so that the scrollTop call below works. Otherwise, have to
      // scroll after that's hidden. or account for the change in advance.
      openElement.data('open', false);
      openElement.hide();

      openElement.prev('.accordion-head').removeClass('open');

      // console.log('opening ' + body.size() + ' elements');

      // now open the body element for this head
      body.data('open', true);
      body.slideDown('fast');

      $(this).addClass('open');

      // and record the current pane on the accordion itself
      accordion.data('openPane', body.data('index'));

      // console.log('set accordion.openPane to ' + accordion.data('openPane'));
    });
    
  });
})(jQuery);
