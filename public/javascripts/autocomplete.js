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
      url = '/.json';
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

  });
})(jQuery);
