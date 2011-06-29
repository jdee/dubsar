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
    var $word_input = $('#word-input');
    var $word_input_has_focus=false;
    var $starting_header=$.find_cookie('dubsar_starting_pane');
    var $show_help_link_timer=null;
    var $hide_help_link_timer=null;
    var $sql_help_link=$('#sql-help-link');
    var $sql_help_dialog;

    /* 'light' or 'dark' */
    $.pick_theme = function(theme) {
      $('body').removeClass('style-light style-dark').addClass('style-'+theme);
      document.cookie = 'dubsar_theme='+theme+'; max-age='+30*86400+'; path=/';

      var other_button_id = $('label#'+theme+'-other').removeClass('ui-state-active').attr('for');
      $('input#'+theme+'-radio').attr('checked','checked');
      $('input#'+other_button_id).removeAttr('checked');
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
      $sql_help_link.html('Huh? SQL wildcards?').fadeIn('slow');
      $show_help_link_timer = null;
    }

    function hide_sql_help_link() {
      $sql_help_link.fadeOut('fast');
      $hide_help_link_timer = null;
    }

    /* style the search button */
    $('#word-submit').button({
      icons: { primary:'ui-icon-search' }
    });

    $('#fairy_name').watermark('name (required)');
    $('#fairy_email').watermark('e-mail (required)');
    $('#fairy_phone_number').watermark('phone number');
    $('#volunteer').button({
      icons: { primary:'ui-icon-person' }
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

    $sql_help_dialog = $('<div>The Structured Query Language used by Dubsar&apos;s PostgreSQL database accepts the following wildcards in searches:<ul><li>% matches anything, including nothing at all</li><li>_ matches any single character</li></ul>For example:<ul><li>%count% matches all words containing <em>count</em></li><li>c_t matches <em>cat, cot</em> and <em>cut</em></li></ul></div>').dialog({
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

    /* DEBT: Need a better test for this without actually triggering
       the 3-second timer and waiting. */
    $word_input.watermark('enter a word');
    $word_input.live('mouseenter', function(){
      if ($hide_help_link_timer !== null) {
        window.clearTimeout($hide_help_link_timer);
        $hide_help_link_timer = null;
      }
      if (!$word_input_has_focus && !$sql_help_link.is(':visible')) {
        $show_help_link_timer = window.setTimeout(show_sql_help_link, 3000);
      }
    }).live('mouseleave', function(){
      if ($show_help_link_timer !== null) {
        window.clearTimeout($show_help_link_timer);
        $show_help_link_timer = null;
      }
      if ($sql_help_link.is(':visible')) {
        $hide_help_link_timer = window.setTimeout(hide_sql_help_link, 20000);
      }
    }).live('focus', function(){
      $word_input_has_focus = true;
      if ($show_help_link_timer !== null) {
        window.clearTimeout($show_help_link_timer);
        $show_help_link_timer = null;
      }
      if ($sql_help_link.is(':visible')) {
        hide_sql_help_link();
      }
    }).live('blur', function(){
      $word_input_has_focus = false;
    });

    $sql_help_link.live('mouseenter', function(){
      if ($hide_help_link_timer !== null) {
        window.clearTimeout($hide_help_link_timer);
        $hide_help_link_timer = null;
      }
    }).live('mouseleave', function(){
      $hide_help_link_timer = window.setTimeout(hide_sql_help_link, 20000);
    }).live('click', function(){
      $sql_help_dialog.dialog('open');
      return false;
    });

    /* Set up the theme picker */
    $('#theme-picker-buttonset > input').button().click(function(){
      $.pick_theme($(this).val());
    })
    $('#theme-picker-buttonset').buttonset();
    $('#theme-picker-buttonset > input:checked').click();

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

      $('span.tooltip').live('mouseenter', function(){
        if ($tt.hasClass('ui-draggable-dragging')) return;

        kill_tooltip();
        $tt.html('');
        $tt.html($('div.template', this).html());
        $('a.close-icon-span', $tt).css({opacity:0});
        $tt.show();
        /* 1 pixel border on each side */
        $('> *', $tt).width($tt.width()-2);
        $tt_gloss = $(this).addClass('ui-state-highlight').css({'border-style':'none'});
      }).live('mouseleave', function(){
        if (!$tt_fixed && !$tt.hasClass('ui-draggable-dragging')) kill_tooltip();
      }).live('mousemove', function(ev){
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
        $tt_timer = setTimeout(fix_tooltip, 300);
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
        $tt.draggable({
          containment: 'window',
          cursor: 'move',
          handle: '.ui-widget-header',
          scroll: false
        });
      }

      kill_tooltip();
    }
  });
})(jQuery);
