$(document).on("turbolinks:load", function() {
  $('select').material_select();

  $('.pushpin-date-range-row').each(function() {
    var $this = $(this);

    $this.pushpin({
      top: $this.offset().top,
      offset: -18
    });
  });
});
