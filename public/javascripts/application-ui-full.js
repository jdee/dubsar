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

/*
 * This file includes more elaborate AJAX for an auto-updating top-ten
 * pane and an autocompleter that retrieves _all_ matching words, in
 * dynamically-sized batches.
 */
;(function($){
  $(function(){
    var $list;
    var $word_input;
    var $word_input_has_focus=false;
    var $request_term;
    var $match='';
    var $starting_header=$.find_cookie('dubsar_starting_pane');
    var $top_ten_interval;
    var $show_help_link_timer=null;
    var $hide_help_link_timer=null;
    var $sql_help_link=$('#sql-help-link');
    var $sql_help_dialog;

    /* 'light' or 'dark' */
    function pick_theme(theme) {
      $('body').removeClass('style-light style-dark').addClass('style-'+theme);
      document.cookie = 'dubsar_theme='+theme+'; max-age='+30*86400+'; path=/';
    }

    function find_starting_pane() {
      if (!$starting_header || $('#' + $starting_header).size() == 0 ||
        ! $('#' + $starting_header + '+ div').attr('id')) {
        set_starting_pane('');
        return 0;
      }
      else {
        var _top = $.find_cookie('dubsar_starting_offset');
        if (_top) $('#main').scrollTop(_top);
        return $('#' + $starting_header + '+ div').attr('id').match(/_(\d+)$/)[1] - 0;
      }
    }

    function set_starting_pane(id) {
      document.cookie = 'dubsar_starting_pane='+id;
      if (id) document.cookie = 'dubsar_starting_offset='+$('#main').scrollTop();
    }

    function kickoff_top_ten() {
      load_top_ten();
      $('div#top-ten-pane').css('opacity', 0.4);
      $top_ten_interval = setInterval(load_top_ten, 30000);
    }

    function stop_top_ten() {
      if ($top_ten_interval) clearInterval($top_ten_interval);
    }

    function load_top_ten() {
      /* DEBT:
       * 80 is overkill, but:
       * Each word can have up to 4 parts of speech and can be
       * capitalized or not.  The offset and limit parameters refer
       * directly to the SQL table index.  For the moment, this is
       * the easiest place to put this logic.  It needs to be
       * improved.
       */
      $.ajax({
        type: 'GET',
        url: '/.json',
        dataType: 'json',
        data: {term:'%', limit:80},
        success: function(response) {
          var results = '<ol>';
          for (var i=0; i<response.list.length && i<10; ++i) {
            var word = response.list[i];
            results += '<li><a href="/?term=' + word + '" title="' +
              word + '">' + word+'</a></li>';
          }
          results += '</ol>';
          $('div#top-ten-pane').html(results).fadeTo('slow', 1.0);
        },
        error: function(xhr, textStatus, errorThrown) {
          $('div#top-ten-pane').fadeTo('fast', 0.4);
        }
      });
    }

    function check_top_ten_pane(event, info) {
      if (info.newHeader.attr('id') == 'cap-top_ten_n') {
        kickoff_top_ten();
      }
      else if (info.oldHeader.attr('id') == 'cap-top_ten_n') {
        stop_top_ten();
      }
    }

    function show_sql_help_link() {
      $sql_help_link.fadeIn('slow');
      $show_help_link_timer = null;
    }

    function hide_sql_help_link() {
      $sql_help_link.fadeOut('fast');
      $hide_help_link_timer = null;
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
      if ($request_term === $word_input.val()) {
        return false;
      }

      $list = new Array();
      $request_term = $word_input.val();
      $word_input.add('.ui-menu').css('cursor', 'wait');
      $('#error').stop(true).replaceWith('<div id="error" class="ui-state-highlight ui-corner-all"><span class="ui-icon ui-icon-info"></span>working...</div>');
      $('#main').stop().animate({ top: '24.7ex' }, 'fast');
    }

    /* cancel any search when the autocompleter closes */
    function ac_close_handler(){
      ac_stop_search();
    }

    function ac_stop_search(){
      $word_input.add('.ui-menu').css('cursor', 'auto');
      $('#error').stop().fadeOut('slow', function(){
        $('#main').stop().animate({ top: $('#header').outerHeight()}, 1000, 'easeOutBounce');
      });
    }

    function ajax_handler(request,response,offset,limit){
      // search for words that start with the search term
      request.term += '%';
      if ($match) {
        request.match = $match;
      }

      /* to start with */
      if (!request.offset) {
        request.offset = 0;
      }
      if (!request.limit) {
        request.limit = 100;
      }

      $.getJSON('/.json', request, function(data){
        // make sure the search term hasn't changed (this might be an
        // old response)
        if (data.term == $request_term && data.match == $match) {
          for (var j=0; j<data.list.length; ++j) $list.push(data.list[j]);
          response($list);

          if (request.offset + request.limit >= data.total) {
            ac_stop_search();
            return;
          }

          // recursively invoke outer function to request the next page
          request.term = $request_term;
          request.offset += request.limit;
          if ($list.length < 400) {
            request.limit = 100;
          }
          else if ($list.length < 1000) {
            request.limit = 200;
          }
          else {
            request.limit = 500;
          }

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
        minLength: 2,
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
      changestart: check_top_ten_pane,
      navigation: true
    });

    if ($starting_header == 'cap-top_ten_n') kickoff_top_ten();

    /* case toggle button */
    $('#word-case').button({
      icons:{
        secondary: 'ui-icon-arrowthick-1-e'
      }
    }).click(function(){
      $list = new Array();
      if ($(this).is(':checked')) {
        $match = $(this).val();
      }
      else {
        $match = '';
      }
    });
    $('#word-lookup-buttonset').buttonset();

    $sql_help_dialog = $('#sql-help-dialog-template').clone().dialog({
      autoOpen   : false        ,
      dialogClass: 'sql-help-dialog',
      height     : 350,
      width      : 450,
      resizable  : false,
      title      : 'SQL wildcards',
      buttons    : {
        ok: function() {
          $(this).dialog('close');
        }
      }
    });

    $word_input.watermark('enter a word');
    $word_input.hover(function(){
      if ($hide_help_link_timer !== null) {
        window.clearTimeout($hide_help_link_timer);
        $hide_help_link_timer = null;
      }
      if (!$word_input_has_focus && !$sql_help_link.is(':visible')) {
        $show_help_link_timer = window.setTimeout(show_sql_help_link, 3000);
      }
    }, function(){
      if ($show_help_link_timer !== null) {
        window.clearTimeout($show_help_link_timer);
        $show_help_link_timer = null;
      }
      if ($sql_help_link.is(':visible')) {
        $hide_help_link_timer = window.setTimeout(hide_sql_help_link, 20000);
      }
    }).focus(function(){
      $word_input_has_focus = true;
      if ($show_help_link_timer !== null) {
        window.clearTimeout($show_help_link_timer);
        $show_help_link_timer = null;
      }
      if ($sql_help_link.is(':visible')) {
        hide_sql_help_link();
      }
    }).blur(function(){
      $word_input_has_focus = false;
    });

    $sql_help_link.hover(function(){
      if ($hide_help_link_timer !== null) {
        window.clearTimeout($hide_help_link_timer);
        $hide_help_link_timer = null;
      }
    }, function(){
      $hide_help_link_timer = window.setTimeout(hide_sql_help_link, 20000);
    }).click(function(){
      $sql_help_dialog.dialog('open');
      return false;
    });

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
    }, function(){
      $(this).removeClass('ui-state-hover');
    }).click(function(){
      $(this).addClass('ui-state-active');
    });
  });
})(jQuery);
