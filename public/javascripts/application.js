(function($){
  /* ready handler */
  $(function(){

    /******** AJAX for autocompleter ********/

    var list;
    var word_input;
    var request_term;

    /* if an item was selected (and popped into the text box), submit
       the request */
    function ac_handler(event,ui){
      if (ui.item) {
        word_input.val($(ui.item).val());
        $('#word-submit').click();
      }
    }

    /* new autocomplete search begins */
    function ac_search_handler(event,ui){
      list = new Array();
      request_term = word_input.val();
    }

    function ajax_handler(request,response,page){
      // search for words that start with the search term
      request.term += '%';

      // get one page at a time
      url = '/words/show.json';
      if (page) url += '?page=' + page;

      $.getJSON(url, request, function(data){
        // make sure the search term hasn't changed (this might be an
        // old response)
        if (data.term == request_term) {
          for (var j=0; j<data.list.length; ++j) list.push(data.list[j]);
          response(list);

          if (!data.page || !data.total || data.page > data.total) return;

          // recursively invoke outer function to request the next page
          request.term = request_term;
          ajax_handler(request, response, data.page);
        }
      });
    }

    /* attach these functions to the autocompleter */
    /* register_autocomplete can be called to supply any other source
       (like a local array) */
    (function register_autocomplete($source) {
      word_input = $('#word-input').autocomplete({
        source:$source,
        select:ac_handler,
        change:ac_handler,
        close:ac_handler,
        search:ac_search_handler
      });
    })(ajax_handler);

    /******** end autocompleter ********/

    /* set up definition accordion divs */
    $('#accordion').accordion({});
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

    /* Set up the theme picker */
    /* The unselected button often continues to appear active even
       after a page reload, so we strip that class on each button
       click and fire the event on page load. */
    $('#theme-picker-buttonset > input').button().click(function(){
      var theme = $(this).val();
      pick_theme(theme);
      $('label#'+theme+'-other').removeClass('ui-state-active');
    });
    $('#theme-picker-buttonset').buttonset();
    $('#theme-picker-buttonset > input:checked').click();

    /* 'light' or 'dark' */
    function pick_theme(theme) {
      // replace the stylesheet links in the <head> element
      $('link[rel="stylesheet"]').replaceWith(
'<link rel="stylesheet" media="screen" type="text/css" href="/stylesheets/ui-'+theme+'ness/jquery-ui-1.8.5.custom.css"/>'+
'<link rel="stylesheet" media="screen" type="text/css" href="/stylesheets/ui-'+theme+'ness/application.css"/>'+
'<link rel="stylesheet" media="screen" type="text/css" href="/stylesheets/common.css"/>'
      );

      // save the choice as a cookie
      document.cookie = 'dubsar_theme='+theme+'; max-age='+30*86400+'; path=/';
    }

    /* This animation is fun, but a little annoying.
    $('a', '#header-bar').hover(function(){
      $(this).effect('pulsate', { times: 1, speed: 'fast' });
    }).mouseout(function(){
      $(this).stop();
    });
     */
  });
})(jQuery);
