$(document).on("turbolinks:load", function(){
  $('.ubiquity_funder_name').on( "autocompleteselect", function( event, ui ) {
    console.log('inside autocomplete select');
  });
});


$(document).on("turbolinks:load", function(){
  $('.ubiquity_funder_name').autocomplete({
    select: function(ui, result) {
      console.log('insided select call back')
      console.log(result.item)
    }
  });
});

function fetchFunderFieldData(doi_id) {
  var host = window.document.location.host;
  var protocol = window.document.location.protocol;
  var fullHost = protocol + '//' + host + '/available_ubiquity_titles/call_datasite?doi_id=' + doi_id;
  var field_array = [];
  $.ajax({
    url: fullHost,
    type: "POST",
    data: {"url": url},
    success: function(result){
      if (result.data.error  === undefined) {
        console.log('populate data')
      } else {
        $(".ubiquity-fields-populated-error").html(result.data.error)
        $(".ubiquity-fields-populated-error").show()
      }
    }
  }) //closes $.ajax
}

