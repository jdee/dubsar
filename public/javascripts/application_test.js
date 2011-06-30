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
module('core');
test('find_cookie', function(){
  var find_cookie = $.find_cookie;
  ok(find_cookie, 'test for find_cookie function');
  document.cookie = 'dubsar_test_cookie=foo';
  equal(find_cookie('dubsar_test_cookie'), 'foo', 'test find_cookie result');

  /* remove the cookie now */
  document.cookie = 'dubsar_test_cookie=; max-age=0';
  equal(find_cookie('dubsar_test_cookie'), '', 'test blank result');
});

test('.pagination link class', function(){
  ok($('.pagination a').hasClass('search-link'), 'test for .search-link class');
});

test('#main div starting position', function(){
  var diff = Math.abs($('#main').position().top - $('#header').outerHeight());
  ok(diff < 1, 'header bottom == main top');
});

test('search-link generates working message', function(){
  $('#pagination-link').trigger('click');
  var text = $('#error').text();
  ok(/working/.test(text), 'look for working message');
});

asyncTest('.header-link-div responds to hover', 1, function(){
  $('.header-link-div').live('hover', function(){
    ok($(this).hasClass('ui-state-hover'), 'div has ui-state-hover class');
  });

  $('.header-link-div').trigger('mouseover');

  setTimeout(function(){
    start();
  }, 100);
});
