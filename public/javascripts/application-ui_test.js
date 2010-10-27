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

/* test setup */
document.cookie = 'dubsar_starting_pane=header_pane_15';
document.cookie = 'dubsar_starting_offset=150';

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

  $('#main').add('#error').hide();
});
