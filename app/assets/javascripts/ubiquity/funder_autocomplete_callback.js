$(document).on("turbolinks:load", function(){
  $('.ubiquity_funder_name').autocomplete({
    select: function(ui, result) {
      console.log('insided select call back')
      console.log(result.item.id)
      closest_div = $('.ubiquity_funder_name').closest('div')
      fetchFunderFieldData(result.item.id, closest_div)
    }
  });
});

function fetchFunderFieldData(doi_id, closest_div) {
  var host = window.document.location.host;
  var protocol = window.document.location.protocol;
  var fullHost = protocol + '//' + host + '/available_ubiquity_titles/call_funder_api';
  var closest_div = closest_div;
  $.ajax({
    url: fullHost,
    type: "POST",
    data: {"doi_id": doi_id},
    success: function(result){
      console.log(result.data);
      console.log(result.data.funder_ror);
      if (result.data.error  === undefined) {
        closest_div.find('.ubiquity_funder_doi').val(result.data.funder_ror)
        closest_div.find('.ubiquity_funder_isni').val(result.data.funder_isni)
        $.each(result.data.funder_awards , function(index, val) {
          console.log(index, val);
          if (index > 0) {
            closest_div.find('.add_another_funder_awards_button').click();
          }
          closest_div.find('.ubiquity_funder_awards:last').val(vak)
        });
      }
    }
  }) //closes $.ajax
}

