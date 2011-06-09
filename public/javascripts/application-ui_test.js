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

var $dubsar_original_theme;

/* test setup */
document.cookie = 'dubsar_starting_pane=header_pane_15';
document.cookie = 'dubsar_starting_offset=150';

/*********** accordion module ***************/
module('accordion');
test('accordion starting pane', function(){
  var starting_pane = $.find_cookie('dubsar_starting_pane');
  ok(starting_pane, 'dubsar_starting_pane found');
  equal(starting_pane, 'header_pane_15', 'dubsar_starting_pane correct');
  ok($('#'+starting_pane+'+div').is(':visible'), 'dubsar_starting_pane open');

  /* a little klugey, but */
  ok($('#pane_0').not(':visible'), 'first pane closed');

});

test('accordion starting offset', function(){
  var starting_offset = $.find_cookie('dubsar_starting_offset');
  ok(starting_offset, 'dubsar_starting_offset found');
  equal($('#main').scrollTop(), starting_offset, 'check starting offset');
});

/***************** theme picker module *****************/
module('theme picker', {
  setup: function(){
    $dubsar_original_theme = $.find_cookie('dubsar_theme');
  },
  teardown: function(){
    $.pick_theme($dubsar_original_theme);
  }
});

test('theme picker button clicks', function(){
  var body = $('body');
  $('#light-radio').click();
  ok(body.hasClass('style-light'), 'check for style-light');
  ok(!body.hasClass('style-dark'), 'check for no style-dark');
  $('#dark-radio').click();
  ok(body.hasClass('style-dark'), 'check for style-dark');
  ok(!body.hasClass('style-light'), 'check for no style-light');
});

/****************** tooltip module ********************/
module('tooltip', {
  teardown: function(){
    $('#tooltip').hide();
  }
});

test('#tooltip div', function(){
  equal($('#tooltip').length, 1, 'there should be 1 #tooltip div');
  equal($('span.tooltip').length, 30, 'there should be 30 .tooltip spans');
  equal($('#pane_15 span.tooltip').length, 1, 'there should be 1 .tooltip span in #pane_15');
  ok($('#pane_15 span.tooltip').is(':visible'), '#pane_15 span.tooltip should be visible');
});

test('hover test', function(){
  $('#pane_15 span.tooltip').trigger('mouseover');
  ok($('#tooltip').is(':visible'), 'hover should show tooltip');
  equal($('#tooltip').width(), $('#tooltip .ui-widget-header').width()+2,
    'tooltip header should be the right width');
  $('#pane_15 span.tooltip').trigger('mouseout');
  ok(!$('#tooltip').is(':visible'), 'mouseout should hide tooltip');
});

/************************ autocompleter module ******************/
module('autocompleter', {
  setup: function() {
    $.mockjax({
      url: '/.json',
      contentType: 'text/json',
      responseText: {
        term: 'a',
        match: '',
        list: [ 'ask', 'also', 'appear', 'all', 'again', 'area', 'add', 'almost', 'always', 'allow' ]
      },
      responseTime: 300
    });
  },
  teardown: function(){
    $('#word-input').val('');
    $('.ui-menu').hide();
  }
});

test('basics', function(){
  equal($('.ui-menu').length, 1, 'there should be 1 .ui-menu');
});

/* look for the wait cursor when the test fires after 300 ms */
asyncTest('wait cursor', 2, function(){
  $('#word-input').val('a').keydown();
  setTimeout(function(){
    equal($('#word-input').css('cursor'), 'wait', '#word-input should have wait cursor');
    equal($('.ui-menu').css('cursor'), 'wait', '.ui-menu should have wait cursor');
    start();
  }, 350);
});

/* after the test above completes, we give the server time to
   respond, then look for the autocompleter */
asyncTest('autocompletion', 5, function(){
  setTimeout(function(){
    ok($('.ui-menu').text(), 'autocompleter menu should have data');
    equal($('.ui-menu li').length, 10, 'autocompleter should have 10 items');
    ok($('.ui-menu').is(':visible'), 'autocompleter menu should be visible');
    equal($('#word-input').css('cursor'), 'auto', '#word-input should have auto cursor');
    equal($('.ui-menu').css('cursor'), 'auto', '.ui-menu should have auto cursor');
    start();
  }, 400);
});

/* can't get this to trigger an autocomplete select event
   this just tests the ac_select_handler, which triggers the search
   form
asyncTest('autocompleter selection', 1, function(){
  $('#word-submit').live('click', function(){
    ok(true, 'search submitted');
    return false;
  });
  $('.ui-menu li:first').click();
  setTimeout(function(){
    start();
  },100);
});
 */

/********************* sql help dialog module *****************/
module('sql help dialog', {
  teardown: function(){
    $('.sql-help-dialog').hide();
  }
});

test('show dialog', function(){
  $('#sql-help-link').click();
  equal($('.sql-help-dialog').length, 1, 'there should be 1 .sql-help-dialog');
  ok($('.sql-help-dialog').is(':visible'), 'it should be visible');
});

/******************* teardown (hide it all) *******************/
module('teardown');
test('teardown, no test', function(){
  $('#header').add('#main').add('#error').add('#footer').hide();
});
