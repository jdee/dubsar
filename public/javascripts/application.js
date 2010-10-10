// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

(function($){
  $(function(){
    function ac_handler(event,ui){
      if (ui.item) {
        word_input.val($(ui.item).val());
        $('#word-submit').click();
      }
    }
    function ajax_handler(request,response){
      // search for words that start with the search term
      request.term += '%';
      $.getJSON('/words/show.json/', request, function(data){
        response(data);
      });
    }
    var word_input = $('#word-input').autocomplete({
      source:ajax_handler,
      select:ac_handler,
      change:ac_handler,
      close:ac_handler
    });

    $('#accordion').accordion({});
    $(':submit').button({
      icons: { primary:'ui-icon-search' }
    });
  });
})(jQuery);
