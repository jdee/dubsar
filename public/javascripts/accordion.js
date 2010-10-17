(function($){
  $(function(){
    function find_starting_pane() {
      var starting_pane = $.find_cookie('dubsar_starting_pane');
      if (!starting_pane || $('#' + starting_pane).size() == 0) {
        set_starting_pane('');
        return 0;
      }
      else {
        location.hash = '#' + starting_pane;
        return $('+ div', '#' + starting_pane).attr('id').match(/_(\d)+$/)[1] - 0;
      }
    }

    function set_starting_pane(id) {
      document.cookie = 'dubsar_starting_pane='+id+'; path=/';
    }

    $('#accordion').accordion({
      active: find_starting_pane(),
      autoHeight: false,
      change: function(event, info) {
        set_starting_pane(info.newHeader.attr('id'));
      },
      navigation: true
    });
  });
})(jQuery);
