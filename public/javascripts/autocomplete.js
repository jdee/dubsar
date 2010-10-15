(function($){
  /* ready handler */
  $(function(){

    /******** AJAX for autocompleter ********/

    var $list;
    var $word_input;
    var $request_term;
    var $_case='';

    /* case toggle button */
    $('#word-case').button({
      icons:{
        secondary: 'ui-icon-arrowthick-1-e'
      }
    }).click(function(){
      $list = new Array();
      if ($(this).is(':checked')) {
        $_case = $(this).val();
      }
      else {
        $_case = '';
      }
    });
    $('#word-lookup-buttonset').buttonset();

    /* if an item was selected (and popped into the text box), submit
       the request */
    function ac_handler(event,ui){
      if (ui.item) {
        $word_input.val($(ui.item).val());
        $('#word-submit').click();
      }
    }

    /* new autocomplete search begins */
    function ac_search_handler(event,ui){
      $list = new Array();
      $request_term = $word_input.val();
    }

    function ajax_handler(request,response,page){
      // search for words that start with the search term
      request.term += '%';
      if (page) {
        request.page = page;
      }
      if ($_case) {
        request['case'] = $_case;
      }

      // get one page at a time
      var url = '/.json';

      $.getJSON(url, request, function(data){
        // make sure the search term hasn't changed (this might be an
        // old response)
        if (data.term == $request_term && data['case'] == $_case) {
          for (var j=0; j<data.list.length; ++j) $list.push(data.list[j]);
          response($list);

          if (!data.page || !data.total || data.page > data.total) return;

          // recursively invoke outer function to request the next page
          request.term = $request_term;
          ajax_handler(request, response, data.page);
        }
      });
    }

    /* attach these functions to the autocompleter */
    /* register_autocomplete can be called to supply any other source
       (like a local array) */
    (function register_autocomplete($source) {
      $word_input = $('#word-input').autocomplete({
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
