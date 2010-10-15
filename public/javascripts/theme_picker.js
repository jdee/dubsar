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
      // replace the stylesheet links in the <head> element
      $('link[rel="stylesheet"]').replaceWith(
'<link rel="stylesheet" media="screen" type="text/css" href="/stylesheets/ui-'+theme+'ness/jquery-ui-1.8.5.custom.css"/>'+
'<link rel="stylesheet" media="screen" type="text/css" href="/stylesheets/ui-'+theme+'ness/application.css"/>'+
'<link rel="stylesheet" media="screen" type="text/css" href="/stylesheets/common.css"/>'
      );

      // save the choice as a cookie
      document.cookie = 'dubsar_theme='+theme+'; max-age='+30*86400+'; path=/';
    }
  });
})(jQuery);
