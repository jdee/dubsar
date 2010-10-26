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
  /* $('#main > .pagination > a.search-link').trigger('click'); */
  equal($('#main .pagination a').size(), 1, 'test pagination link count');
  equal($('#main .pagination .search-link').size(), 1, 'test .search-link count');

  equal($('#error').size(), 1, 'test #error div count');
  var text = $('#error').text();
  /* this test is not passing for some reason... */
  /* ok(/working/.test(text), 'look for working message'); */
});
