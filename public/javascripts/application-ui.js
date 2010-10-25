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
    var $list;
    var $word_input;
    var $request_term;
    var $_case='';

    /* 'light' or 'dark' */
    function pick_theme(theme) {
      $('body').removeClass('style-light style-dark').addClass('style-'+theme);
      document.cookie = 'dubsar_theme='+theme+'; max-age='+30*86400+'; path=/';
    }

    function find_starting_pane() {
      var starting_pane = $.find_cookie('dubsar_starting_pane');
      if (!starting_pane || $('#' + starting_pane).size() == 0 ||
        ! $('#' + starting_pane + '+ div').attr('id')) {
        set_starting_pane('');
        return 0;
      }
      else {
        var _top = $.find_cookie('dubsar_starting_offset');
        if (_top) $('#main').scrollTop(_top);
        return $('#' + starting_pane + '+ div').attr('id').match(/_(\d+)$/)[1] - 0;
      }
    }

    function set_starting_pane(id) {
      document.cookie = 'dubsar_starting_pane='+id;
      if (id) {
        var offset = $('#main').scrollTop() + $('#' + id).position().top;
        document.cookie = 'dubsar_starting_offset='+offset;
      }
    }

    /* if an item was selected, submit the request */
    function ac_select_handler(event,ui){
      if (ui.item) {
        $word_input.val($(ui.item).val());
        $('#word-submit').click();
      }
    }

    /* new autocomplete search begins */
    function ac_search_handler(){
      $list = new Array();
      $request_term = $word_input.val();
    }

    /* cancel any search when the autocompleter closes */
    function ac_close_handler(){
      $request_term = null;
    }

    function ajax_handler(request,response,page){
      // search for words that start with the search term
      request.term += '%';
      if (page) {
        request.page = page;
      }
      if ($_case) {
        request['case'] = $_case;
      }

      $.getJSON('/.json', request, function(data){
        // make sure the search term hasn't changed (this might be an
        // old response)
        if (data.term == $request_term && data['case'] == $_case) {
          for (var j=0; j<data.list.length; ++j) $list.push(data.list[j]);
          response($list);

          if (!data.next_page || !data.total || data.next_page > data.total) return;

          // recursively invoke outer function to request the next page
          request.term = $request_term;
          ajax_handler(request, response, data.next_page);
        }
      });
    }

    /* attach these functions to the autocompleter */
    /* register_autocomplete can be called to supply any other source
       (like a local array) */
    (function register_autocomplete($source) {
      $word_input = $('#word-input').autocomplete({
        close :ac_close_handler,
        search:ac_search_handler,
        select:ac_select_handler,
        source:$source
      });
    })(ajax_handler);

    /* style the search button */
    $(':submit').button({
      icons: { primary:'ui-icon-search' }
    });

    $('#accordion').accordion({
      active: find_starting_pane(),
      autoHeight: false,
      change: function(event, info) {
        set_starting_pane(info.newHeader.attr('id'));
      },
      navigation: true
    });

    /* case toggle button */
    $('#word-case').button({
      icons:{
        secondary: 'ui-icon-arrowthick-1-e'
      }
    }).click(function(){
      $list = new Array();
      if ($(this).is(':checked')) {
        $_case = $(this).val();
      }
      else {
        $_case = '';
      }
    });
    $('#word-lookup-buttonset').buttonset();

    $word_input.watermark('enter a word');

    /* Set up the theme picker */
    $('#theme-picker-buttonset > input').button().click(function(){
      var theme = $(this).val();
      pick_theme(theme);
      $('label#'+theme+'-other').removeClass('ui-state-active');

      /* DEBT: Review these IDS */
      /* the 'light' button label */
      $('#dark-other').addClass('ui-corner-left');
      /* the 'dark'  button label */
      $('#light-other').addClass('ui-corner-right');
    })
    $('#theme-picker-buttonset').buttonset();
    $('#theme-picker-buttonset > input:checked').click();

    /* jquery.watermark adds a span within a span, resulting in extra
       margins and huge buttons; we remove the inner span */
    $('.small-buttonset span > span').unwrap();

    $('#tour a').each(function(){
      var id  = $(this).attr('id');
      var url = $(this).attr('href');
      var title = $('h3', this).text() || '';
      $('<div id="'+id+'-dialog"><img src="'+url+'"/></div>').dialog({
        autoOpen   : false        ,
        dialogClass: 'tour-dialog',
        height     : 655,
        width      : 930,
        title      : title
      });
      $(this).click(function(){
        $('#'+id+'-dialog').dialog('open');
        return false;
      });
    });

    $('#tour-link-div').hover(function(){
      $(this).addClass('ui-state-hover');
    }).mouseleave(function(){
      $(this).removeClass('ui-state-hover');
    }).click(function(){
      $(this).addClass('ui-state-active');
    });
  });
})(jQuery);