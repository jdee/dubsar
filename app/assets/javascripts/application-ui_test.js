/*
  Dubsar Dictionary Project
  Copyright (C) 2010-13 Jimmy Dee

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
  ok($('#pane_0').is(':hidden'), 'first pane closed');

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

test('active theme picker button hover state', function(){
  $('input#light-radio').click();
  $('label[for="light-radio"]').trigger('mouseenter');
  ok($('label#dark-other').hasClass('ui-state-hover'), 'label has hover state');
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
  ok($('#tooltip').is(':hidden'), 'mouseout should hide tooltip');
});

/************************ autocompleter module ******************/
module('autocompleter', {
  setup: function() {
    $.mockjax({
      url: '/os.json',
      contentType: 'text/json',
      responseText: [ 'a', [ 'ask', 'also', 'appear', 'all', 'again', 'area', 'add', 'almost', 'always', 'allow' ] ],
      responseTime: 300
    });
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

asyncTest('autocompletion', 5, function(){
  $('#word-input').val('a').keydown();
  setTimeout(function(){
    ok($('.ui-menu').text(), 'autocompleter menu should have data');
    equal($('.ui-menu li').length, 10, 'autocompleter should have 10 items');
    ok($('.ui-menu').is(':visible'), 'autocompleter menu should be visible');
    equal($('#word-input').css('cursor'), 'auto', '#word-input should have auto cursor');
    equal($('.ui-menu').css('cursor'), 'auto', '.ui-menu should have auto cursor');
    start();
  }, 800);
});

asyncTest('autocompleter selection', 1, function(){
  var input = $('#word-input');
  var menu = input.autocomplete('widget');

  $('form').live('submit', function(){
    ok(input.val() == 'ask', 'correct search submitted');
    return false;
  });

  input.val('a').keydown();

  setTimeout(function(){
    var ev = $.Event('keydown');
    ev.keyCode = $.ui.keyCode.DOWN;
    input.trigger(ev);

    ev = $.Event('keydown');
    ev.keyCode = $.ui.keyCode.ENTER;
    input.trigger(ev);

    setTimeout(function(){
      start();
    }, 100);
  }, 800);
});

asyncTest('hide menu on clear', 1, function(){
  var input = $('input#word-input');
  var menu = input.autocomplete('widget');

  input.val('').trigger('input');
  setTimeout(function(){
    ok(menu.is(':hidden'), 'menu should not be visible');
    start();
  }, 100);
});

/********************* sql help dialog module *****************/
module('sql help dialog', {
  teardown: function(){
    $('.sql-help-dialog').hide();
  }
});

asyncTest('show dialog', 4, function(){
  equal($('a#sql-help-link-anchor').size(), 0, 'there is no #sql-help-link-anchor to begin with');
  $('input#word-input').trigger('mouseenter');
  setTimeout(function(){
    ok($('a#sql-help-link-anchor').is(':visible'), '#sql-help-link-anchor becomes visible');
    $('a#sql-help-link-anchor').click();
    equal($('.sql-help-dialog').size(), 1, 'there should be 1 .sql-help-dialog');
    ok($('.sql-help-dialog').is(':visible'), 'it should be visible');
    start();
  }, 3500);
});

/******************* share dialog module **********************/
module('share dialog', {
  setup: function(){
    $.mockjax({
      url: '/share',
      responseTime: 50,
      responseText: 'The people have a right to know about Dubsar!'
    });
  },
  teardown: function() {
    $('div#share-dialog').dialog('close');
  }
});

asyncTest('share link shows dialog', 2, function() {
  var link = $('a#share-link');
  var dialog = $('div#share-dialog');
  link.click();
  setTimeout(function(){
    ok(dialog.is(':visible'), 'dialog visible');
    ok(/The people have a right to know about Dubsar!/.test(dialog.text()), 'dialog retrieves AJAX text');
    start();
  }, 100);
});

/******************* teardown (hide it all) *******************/
module('teardown');
test('teardown, no test', function(){
  $('#header').add('#main').add('#error').add('#footer').hide();
  $('.header-link-div').removeClass('ui-state-active ui-state-hover').addClass('ui-state-default');
});
