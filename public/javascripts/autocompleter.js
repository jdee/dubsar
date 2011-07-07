/*
  Dubsar Dictionary Project
  Copyright (C) 2010-11 Jimmy Dee

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
    var $match='';

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
      /* search for words that start with the search term */
      request.term += '%';
      if ($match) {
        request.match = $match;
      }

      request.offset = 0;
      /*
       * The controller collapses the results by case and part of
       * speech, e.g. cold (n.) and cold (v.) as well as man (n.) and
       * Man (n.) (the island).  In order to insure that we always
       * have ten results to display, we have to request at least 80
       * each time (four parts of speech, times capitalized vs.
       * uncapitalized--assuming those are the only case variations
       * for any word.  But in most cases, we get 80 results back or
       * nearly so and then display only the first 10.  It seems much
       * more sensible for the time being to display fewer than 10 in
       * cases where the controller collapses a result set.
       */
      request.limit = 10;

      $.ajax({
        type: 'GET',
        url: '/.json',
        dataType: 'json',
        data: request,
        success: function(data){
          /* make sure the search term hasn't changed (this might be an old response) */
          if ($list && data.term == $request_term && data.match == $match) {
            for (var j=0; j<data.list.length; ++j) $list.push(data.list[j]);
            response($list);
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
