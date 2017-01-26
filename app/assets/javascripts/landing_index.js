$(document).ready(function() {
  $(".pushpin-date-range-row").on("click", "a", function(e) {
    $.ajax({
      url: "/",
      dataType: 'script',
      data: { date_range: e.target.text }
    })
  });
});
