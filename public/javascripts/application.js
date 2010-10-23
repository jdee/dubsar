(function($){
  $(function(){
    /* find the value currently associated with a cookie by name */
    /* (blank string if not found) */
    $.find_cookie = function(name){
      var allcookies = document.cookie;
      var pos = allcookies.indexOf(name);
      if (pos != -1) {
        var start = pos + name.length + 1;
        var end = allcookies.indexOf(';', start);
        if (end == -1) {
          end = allcookies.length;
        }
        return decodeURIComponent(allcookies.substring(start, end));
      }
      else {
        return '';
      }
    };

    /* style the search button */
    $(':submit').button({
      icons: { primary:'ui-icon-search' }
    });

    $('.pagination a').addClass('search-link');

    $('.search-link').click(post_info);

    /* position the main div depending on whether the error div is
       present */
    var $error_div = $('#error');
    var $header_div = $('#header');
    var $main_div = $('#main');
    var $header_bottom = $header_div.outerHeight();
    var $starting_offset = $header_bottom;
    $error_div.filter(':visible').each(function(){
      $starting_offset = $(this).position().bottom;
    });
    $main_div.css({ top: $starting_offset });

    /* fade the error div */
    $error_div.filter(':visible').delay(3000).fadeOut('slow', function(){
      $main_div.animate({ top: $header_bottom }, 1000, 'easeOutBounce');
    });

    function post_info(){
      /* just cheat off the stylesheet and don't try to compute the offset */
      $main_div.stop().animate({ top: '22.8ex' }, 'fast');
      $error_div.stop().replaceWith('<div id="error" class="ui-state-highlight ui-corner-all"><span class="ui-icon ui-icon-info"></span>working...</div>');
    }
  });
})(jQuery);
