(function($){
  $(function(){
    function find_starting_pane() {
      var starting_pane = $.find_cookie('dubsar_starting_pane');
      if (!starting_pane || $('#' + starting_pane).size() == 0 ||
        ! $('#' + starting_pane + '+ div').attr('id')) {
        set_starting_pane('');
        return 0;
      }
      else {
        var _top = $.find_cookie('dubsar_starting_offset');
        if (_top) $('#main').scrollTop(_top);
        return $('#' + starting_pane + '+ div').attr('id').match(/_(\d+)$/)[1] - 0;
      }
    }

    function set_starting_pane(id) {
      document.cookie = 'dubsar_starting_pane='+id;
      if (id) {
        var offset = $('#main').scrollTop() + $('#' + id).position().top;
        document.cookie = 'dubsar_starting_offset='+offset;
      }
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
