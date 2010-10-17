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

    /* position the main div depending on whether the error div is
       present */
    var $error_div = $('#error');
    var $header_div = $('#header');
    var $main_div = $('#main');
    var $header_bottom = $header_div.outerHeight();
    var $starting_offset = $header_bottom;
    $error_div.each(function(){
      $starting_offset = $(this).position().bottom;
    });
    $main_div.css({ top: $starting_offset });

    /* fade the error div */
    $error_div.delay(3000).fadeOut('slow', function(){
      $main_div.animate({ top: $header_bottom }, 'fast');
    });

    /* This animation is fun, but a little annoying.
    $('a', '#header-bar').hover(function(){
      $(this).effect('pulsate', { times: 1, speed: 'fast' });
    }).mouseout(function(){
      $(this).stop();
    });
     */
  });
})(jQuery);
