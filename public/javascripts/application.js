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
    }

    /* style the search button */
    $(':submit').button({
      icons: { primary:'ui-icon-search' }
    });

    /* starts-with toggle button */
    $('#word-starts-with').button({
      icons:{
        secondary: 'ui-icon-arrowthick-1-e'
      }
    });
    $('#word-lookup-buttonset').buttonset();

    /* fade the error div */
    $('#error').delay(3000).fadeOut('slow');

    /* This animation is fun, but a little annoying.
    $('a', '#header-bar').hover(function(){
      $(this).effect('pulsate', { times: 1, speed: 'fast' });
    }).mouseout(function(){
      $(this).stop();
    });
     */
  });
})(jQuery);
