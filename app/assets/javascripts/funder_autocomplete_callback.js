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

