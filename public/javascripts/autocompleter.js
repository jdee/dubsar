/*
  Dubsar Dictionary Project
  Copyright (C) 2010-12 Jimmy Dee

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
    var $list;
    var $word_input;
    var $word_input_has_focus=false;
    var $request_term;

    /* if an item was selected, submit the request */
    function ac_select_handler(event,ui){
      if (ui.item) { $word_input.val(ui.item.value); }
      $(this).closest('form').submit();
    }

    /* new autocomplete search begins */
    function ac_search_handler(){
      if ($request_term === $word_input.val()) {
        return false;
      }

      $list = new Array();
      $request_term = $word_input.val();
      $word_input.add('.ui-menu').css('cursor', 'wait');
    }

    /* cancel any search when the autocompleter closes */
    function ac_close_handler(){
      ac_stop_search();
    }

    function ac_stop_search(){
      $word_input.add('.ui-menu').css('cursor', 'auto');
    }

    function ajax_handler(request,response,offset,limit){
      if ($('input#word-case').is(":checked")) request.match = 'case';
      $.ajax({
        type: 'GET',
        url: '/os.json',
        dataType: 'json',
        data: request,
        success: function(data){
          var term = data[0];
          var results = data[1];
          /* make sure the search term hasn't changed (this might be an old response) */
          if ($list && term == $request_term) {
            response(results);
          }
          ac_stop_search();
        },
        error: function() {
          ac_stop_search();
        }
      });
    }

    /* attach these functions to the autocompleter */
    /* register_autocomplete can be called to supply any other source
       (like a local array) */
    (function register_autocomplete($source) {
      $word_input = $('input#word-input').autocomplete({
        close :ac_close_handler,
        minLength: 1,
        search:ac_search_handler,
        select:ac_select_handler,
        source:$source
      });
    })(ajax_handler);

    /* handle the deletion X in an HTML 5 search field */
    $word_input.live('input', function() {
      if (! $word_input.val()) {
        $word_input.autocomplete('widget').hide();
      }
    }).live('click', function() {
      if (! $word_input.val()) {
        $word_input.autocomplete('widget').hide();
      }
    });
  });
})(jQuery);
