// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

(function($){
  $(function(){
    $('#word-input').autocomplete({
      source:'/words/starts_with.json/',
      close:function(){
        $('#word-submit').click();
      }
    });
  });
})(jQuery);
