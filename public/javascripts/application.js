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
    var word_input = $('#word-input').autocomplete({
      source:'/words/starts_with.json/',
      select:ac_handler,
      change:ac_handler,
      close:ac_handler
    });

    $('#accordion').accordion({});
  });
})(jQuery);
