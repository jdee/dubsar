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
    var $word_input_has_focus=false;
    var $request_term;
    var $match='';
    var $starting_header=$.find_cookie('dubsar_starting_pane');
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
    }

    /* cancel any search when the autocompleter closes */
    function ac_close_handler(){
      ac_stop_search();
    }

    function ac_stop_search(){
      $word_input.add('.ui-menu').css('cursor', 'auto');
    }

    function ajax_handler(request,response,offset,limit){
      // search for words that start with the search term
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
          // make sure the search term hasn't changed (this might be an
          // old response)
          if (data.term == $request_term && data.match == $match) {
            for (var j=0; j<data.list.length; ++j) $list.push(data.list[j]);
            response($list);
          }
          ac_stop_search();
        },
        error: function() {
          $('#error').stop(true).replaceWith('<div id="error" class="ui-state-error ui-corner-all line"><span class="ui-icon ui-icon-alert"></span>error communicating with Dubsar server</div>');
          $('#main').stop().animate({ top: '24.7ex' }, 'fast');
          setTimeout(function(){
            $('#error').fadeOut('slow', function(){
              $('#main').animate({ top: '20.7ex' }, 1000, 'easeOutBounce');
            });
          }, 3000);
          ac_stop_search();
        }
      });
    }

    /* attach these functions to the autocompleter */
    /* register_autocomplete can be called to supply any other source
       (like a local array) */
    (function register_autocomplete($source) {
      $word_input = $('#word-input').autocomplete({
        close :ac_close_handler,
        minLength: 1,
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
      changestart: kill_tooltip,
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

    /* based on a recipe from the O'Reilly jQuery Cookbook */
    var $tt = null;
    var $tt_timer = null;
    var $tt_fixed = false;
    var $tt_gloss = null;
    function kill_tooltip(){
      if ($tt) {
        $tt.hide();
      }
      if ($tt_timer) {
        clearTimeout($tt_timer);
        $tt_timer = null;
      }
      $tt_fixed = false;
      if ($tt_gloss) {
        $tt_gloss.removeClass('ui-state-highlight');
      }
    }

    if ($('span.tooltip').length) {
      $('body').append('<div id="tooltip" class="ui-widget-content ui-corner-all"></div>');
      $tt = $('#tooltip');

      $('span.tooltip').hover(function(){
        kill_tooltip();
        $tt.html($('div.template', this).html());
        $('a.close-icon-span', $tt).css({opacity:0});
        $tt.show();
        $tt_gloss = $(this).addClass('ui-state-highlight').css({'border-style':'none'});
      },
      function(){
        if (!$tt_fixed) kill_tooltip();
      }).mousemove(function(ev){
        if (!$tt_fixed) {
          var $ev_x = ev.pageX;
          var $ev_y = ev.pageY;
          var $tt_x = $tt.outerWidth();
          var $tt_y = $tt.outerHeight();
          var $bd_x = $(window).width();
          var $bd_y = $(window).height();
          $tt.css({
            'top': $ev_y + $tt_y + 15 > $bd_y ? $ev_y - $tt_y < 10 ? 5 : $ev_y - $tt_y - 5 : $ev_y + 10,
            'left': $ev_x + $tt_x + 15 > $bd_x ? $ev_x - $tt_x - 5 : $ev_x + 10
          });
        }

        if ($tt_timer) {
          clearTimeout($tt_timer);
        }
        $tt_timer = setTimeout(fix_tooltip, 1500);
      });

      function fix_tooltip() {
        $tt_fixed = true;
        $tt_timer = null;
        $('.close-icon-span', $tt).click(function(){
          kill_tooltip();
          return false;
        }).hover(function(){
          $(this).addClass('ui-state-hover').removeClass('ui-state-default');
        }, function(){
          $(this).removeClass('ui-state-hover').addClass('ui-state-default');
        }).fadeTo('fast', 1.0);
        $tt.draggable({});
      }

      kill_tooltip();
    }
  });
})(jQuery);
