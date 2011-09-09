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
    var $starting_header=$.find_cookie('dubsar_starting_pane');
    var $show_help_link_timer=null;
    var $hide_help_link_timer=null;
    var $sql_help_link=$('#sql-help-link');
    var $sql_help_dialog;
    var $share_dialog=$('div#share-dialog');
    var $tt = null;
    var $tt_timer = null;
    var $tt_fixed = false;
    var $tt_gloss = null;
    var $opensearch_dialog=$('div#opensearch-dialog');

    /* 'light' or 'dark' */
    $.pick_theme = function(theme) {
      $('body').removeClass('style-light style-dark').addClass('style-'+theme);
      document.cookie = 'dubsar_theme='+theme+'; max-age='+30*86400+'; path=/';

      var other_button_id = $('label#'+theme+'-other').removeClass('ui-state-active').attr('for');
      $('input#'+theme+'-radio').attr('checked','checked');
      $('input#'+other_button_id).removeAttr('checked');

      if ($share_dialog.is(":visible")) $share_dialog.load("/share");
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
      $sql_help_link.html('<div class="ui-state-default ui-corner-all header-link-div" id="sql-help-link-close" style="float: left; margin-right: 0.3em; position: relative; top: 0.2em;"><span class="ui-icon ui-icon-circlesmall-close"></span></div><a id="sql-help-link-anchor" href="#" title="explain" style="position: relative; top: 0.3em;">Huh? SQL Wildcards?</a>').fadeIn('slow');
      $show_help_link_timer = null;
    }

    function hide_sql_help_link() {
      $sql_help_link.fadeOut('fast');
      $hide_help_link_timer = null;
    }

    function kill_sql_help_link() {
      $sql_help_link.hide();
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

    $share_dialog.dialog({
      autoOpen: false,
      open: function() { $(this).load('/share'); },
      height: 300,
      width: 450,
      title: 'Share Dubsar'
    });
    $('a#share-link').live('click', function() { $share_dialog.dialog('open'); return false; });

    $sql_help_dialog = $('<div>The Structured Query Language used by Dubsar&apos;s SQLite database accepts the following wildcards in searches:<ul><li>% matches anything, including nothing at all</li><li>_ matches any single character</li></ul>For example:<ul><li>%count% matches all words containing <em>count</em></li><li>c_t matches <em>cat, cot</em> and <em>cut</em></li></ul></div>').dialog({
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
      if ($sql_help_link.is(':hidden')) {
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
    });

    $sql_help_link.live('mouseenter', function(){
      if ($hide_help_link_timer !== null) {
        window.clearTimeout($hide_help_link_timer);
        $hide_help_link_timer = null;
      }
    }).live('mouseleave', function(){
      $hide_help_link_timer = window.setTimeout(hide_sql_help_link, 20000);
    });

    $('a#sql-help-link-anchor').live('click', function(){
      $sql_help_dialog.dialog('open');
      hide_sql_help_link();
      return false;
    });

    /* Set up the theme picker */
    $('#theme-picker-buttonset > input').button().click(function(){
      $.pick_theme($(this).val());
    });
    $('#theme-picker-buttonset > label').live('mouseenter', function() {
      $(this).removeClass('ui-state-active');
      $(this).addClass('ui-state-hover');
    }).live('mouseleave', function() {
      var checked_input_id = $('#theme-picker-buttonset > input:checked').attr('id');
      $('label[for="' + checked_input_id + '"]').addClass('ui-state-active');
      $(this).removeClass('ui-state-hover');
    });
    $('#theme-picker-buttonset').buttonset();
    $('#theme-picker-buttonset > input:checked').click();

    $('#tour a').each(function(){
      var id  = $(this).attr('id');
      var url = $(this).attr('href');
      var title = $('h3', this).text() || '';
      $('<div id="'+id+'-dialog"><img src="'+url+'" height="600" width="940"/></div>').dialog({
        autoOpen   : false        ,
        dialogClass: 'tour-dialog',
        height     : 650,
        width      : 970,
        title      : title
      });
      $(this).click(function(){
        $('#'+id+'-dialog').dialog('open');
        return false;
      });
    });

    $('.header-link-div').live('mouseenter', function(){
      $(this).addClass('ui-state-hover');
    }).live('mouseleave', function(){
      $(this).removeClass('ui-state-hover ui-state-active');
    }).live('click', function(){
      $(this).addClass('ui-state-active');
    });

    $('div#sql-help-link-close').live('click', function(){
      kill_sql_help_link();
    });

    $('div#sense-tabs').tabs({
      cache: true,
      select: function(){
        kill_tooltip();
      },
      spinner: '[...]'
    });

    /* based on a recipe from the O'Reilly jQuery Cookbook */
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
      });
      $('a.close-icon-span[style*="opacity: 0;"]', $tt).fadeTo('fast', 1.0);
      $tt.draggable({
        containment: 'window',
        cursor: 'move',
        handle: '.ui-widget-header',
        scroll: false
      });
    }

    kill_tooltip();

    /* OpenSearch dialog */

    function setup_opensearch_dialog() {
      $opensearch_dialog.html('<div><p>Search Dubsar easily from your browser&apos;s search bar, complete with live suggestions.</p><div id="opensearch-buttonset"><button tabindex="-1" id="opensearch-add">add</button><button tabindex="-1" id="opensearch-cancel">cancel</button></div></div>');

      $('div#opensearch-buttonset').buttonset();
      $('button#opensearch-add').button({icons:{primary:'ui-icon-plus'}})
        .click(function() {
          window.external.AddSearchProvider(window.location.protocol + "//" + window.location.host + $('link[rel="search"]').attr('href'));
          $opensearch_dialog.dialog('close');
          return false;
      });
      $('button#opensearch-cancel').button({icons:{primary:'ui-icon-close'}})
        .click(function() {
        $opensearch_dialog.dialog('close');
        return false;
      });
    }

    if (window.chrome) {
      $opensearch_dialog.html('<div><p>Chrome automatically added Dubsar as a search provider when you visited this page.</p><p>See <em>Manage Search Engines</em> under Chrome Preferences or <a href="http://www.google.com/support/chrome/bin/answer.py?answer=95653" target="_blank" tabindex="-1">Chrome Help</a> for more information.</p></div>');
    }
    else if (window.external && window.external.AddSearchProvider) {
      setup_opensearch_dialog();
    }
    else {
      $opensearch_dialog.html('<div>This browser does not support the OpenSearch protocol. Use Internet Explorer 8, Firefox or Chrome if you wish to add Dubsar to your browser&apos;s search providers.</div>');
    }

    $opensearch_dialog.dialog({
      autoOpen: false,
      title: 'OpenSearch'
    });

    $('a#opensearch-link').live('click', function() {
      $opensearch_dialog.dialog('open');
      return false;
    });
  });
})(jQuery);
