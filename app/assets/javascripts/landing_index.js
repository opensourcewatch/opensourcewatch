$(document).on("turbolinks:load", function() {
  // Get rid of overlay if it exists
  $(".button-collapse").sideNav();
  $("#sidenav-overlay").remove();
  
  $("body").css("overflow", "visible");
  $(document).on("click", ".pushpin-date-range-row a", function(e) {
    var date_range = e.target.text.toLowerCase();

    var push_the_state = true;
    if (event.type === 'popstate') {
      push_the_state = false;
    }

    $.ajax({
      url: "/",
      dataType: 'script',
      data: { date_range: date_range }
    }).success(function() {
      if (push_the_state) {
        var hostname = $(location).attr('hostname');
        window.history.pushState({ date_range: date_range }, null, date_range);
      }
    });
  });
});

$(window).on('popstate', function(e) {
  var date_range = event.state.date_range;
  $('.' + date_range).trigger('click');
});
