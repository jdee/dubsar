(function($){
  $(function(){
    /* Set up the theme picker */
    $('#theme-picker-buttonset > input').button().click(function(){
      var theme = $(this).val();
      pick_theme(theme);
      $('label#'+theme+'-other').removeClass('ui-state-active');

      /* DEBT: Review these IDS */
      /* the 'light' button label */
      $('#dark-other').addClass('ui-corner-left');
      /* the 'dark'  button label */
      $('#light-other').addClass('ui-corner-right');
    })
    $('#theme-picker-buttonset').buttonset();
    $('#theme-picker-buttonset > input:checked').click();

    /* 'light' or 'dark' */
    function pick_theme(theme) {
      $('body').removeClass('style-light style-dark').addClass('style-'+theme);
      document.cookie = 'dubsar_theme='+theme+'; max-age='+30*86400+'; path=/';
    }

    /* jquery.watermark adds a span within a span, resulting in extra
       margins and huge buttons; we remove the inner span */
    $('.small-buttonset span > span').each(function(){
      $(this).unwrap();
    });
  });
})(jQuery);
