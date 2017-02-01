$(document).ready( function() {
  $("ul.tabs").tabs();

  $('.pushpin-date-range-row').each(function() {
    var $this = $(this);

    $this.pushpin({
      top: $this.offset().top,
      offset: -18
    });
  });
});
