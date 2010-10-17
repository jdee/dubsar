(function($){
  $(function(){
    /* Set up the theme picker */
    $('#theme-picker-buttonset > input').button().click(function(){
      var theme = $(this).val();
      pick_theme(theme);
      $('+ label', this).children('span').andSelf().removeClass('ui-state-default').addClass('ui-state-active');
      $('label#'+theme+'-other').children('span').andSelf().removeClass('ui-state-active').addClass('ui-state-default');

      /* DEBT: Review these IDS */
      /* the 'light' button label */
      $('#dark-other').addClass('ui-corner-left');
      /* the 'dark'  button label */
      $('#light-other').addClass('ui-corner-right');
    });
    $('#theme-picker-buttonset').buttonset();
    $('#theme-picker-buttonset > input:checked').click();

    /* 'light' or 'dark' */
    function pick_theme(theme) {
      $('body').removeClass('style-light style-dark').addClass('style-'+theme);
      document.cookie = 'dubsar_theme='+theme+'; max-age='+30*86400+'; path=/';
    }
  });
})(jQuery);
