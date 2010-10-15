(function($){
  $(function(){
    /* set up definition accordion divs */
    $('#accordion').accordion({});

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
