(function($){
  $(function(){
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
      if (theme == 'dark') {
        $('body').removeClass('style-light').addClass('style-dark');
      }
      else {
        $('body').removeClass('style-dark').addClass('style-light');
      }

      // save the choice as a cookie
      document.cookie = 'dubsar_theme='+theme+'; max-age='+30*86400+'; path=/';
    }
  });
})(jQuery);
