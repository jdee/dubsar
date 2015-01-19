/*
  Dubsar Dictionary Project
  Copyright (C) 2010-15 Jimmy Dee

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
;(function($) {
  $(function() {
    var acResults = $('#autocomplete-results');
    var searchField = $('#search-term');
    var acHighlighted = false;
    var nextSequence = 0;

    function getScope() {
      var scope = "words";
      if ($('#scope_synsets').is(':checked')) scope = "synsets";
      return scope;
    }

    function triggerAutocomplete() {
      if (checkReset('#search-term')) return;

      var term = searchField.val();
      var scope = getScope();

      $.ajax({
        beforeSend: function(jqxhr) {
          jqxhr.dubsarSeqnum = ++ nextSequence;
        },
        url: '/os?term=' + term + '&scope=' + scope,
        type: 'GET',
        dataType: 'html',
        success: function(data, textStatus, jqxhr) {
          if (jqxhr.dubsarSeqnum < nextSequence) return;
          acResults.html(data).show();
        },
        error: function(error) {
          alert(error);
        }
      });
    }

    function checkReset(elm) {
      if ($(elm).val() == '') {
        acResults.html('').hide();
        return true;
      }
      return false;
    }

    searchField.on('input focus', triggerAutocomplete);
    //*
    searchField.on('blur', function() {
      if (acHighlighted) return;
      acResults.hide();
    });
    // */

    acResults.hover(function() {
      acHighlighted = true;
    }, function() {
      acHighlighted = false;
    });

    /* Chrome only: This hides the AC when going back to the index. (But not Safari.) */
    checkReset('#search-term');

    $('input[name="scope"]').on('change', function() {
      searchField.focus();
      triggerAutocomplete();
    });
    
  });
})(jQuery);
