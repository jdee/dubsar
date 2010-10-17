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

    /* if an item was selected, submit the request */
    function ac_select_handler(event,ui){
      if (ui.item) {
        $word_input.val($(ui.item).val());
        $('#word-submit').click();
      }
    }

    /* new autocomplete search begins */
    function ac_search_handler(){
      $list = new Array();
      $request_term = $word_input.val();
    }

    /* cancel any search when the autocompleter closes */
    function ac_close_handler(){
      $request_term = null;
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

      $.getJSON('/.json', request, function(data){
        // make sure the search term hasn't changed (this might be an
        // old response)
        if (data.term == $request_term && data['case'] == $_case) {
          for (var j=0; j<data.list.length; ++j) $list.push(data.list[j]);
          response($list);

          if (!data.next_page || !data.total || data.next_page > data.total) return;

          // recursively invoke outer function to request the next page
          request.term = $request_term;
          ajax_handler(request, response, data.next_page);
        }
      });
    }

    /* attach these functions to the autocompleter */
    /* register_autocomplete can be called to supply any other source
       (like a local array) */
    (function register_autocomplete($source) {
      $word_input = $('#word-input').autocomplete({
        close :ac_close_handler,
        search:ac_search_handler,
        select:ac_select_handler,
        source:$source
      });
    })(ajax_handler);

    /******** end autocompleter ********/

  });
})(jQuery);
