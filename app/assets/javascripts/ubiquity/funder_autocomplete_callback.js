$(document).on("turbolinks:load", function(){
  $('.ubiquity_funder_name').autocomplete({
    select: function(ui, result) {
      closest_div = $(this).closest('div')
      closest_div.find('.ubiquity_funder_doi').val('')
      
      //remove all funder award except the first
      closest_div.find('.funder_awards_input_fields_wrap li').not(':first').remove();
      //set first funder_award to empty string
      closest_div.find('.funder_awards_input_fields_wrap li:first-child input')[0].value = ''

      closest_div.find('.ubiquity_funder_doi').val(result.item.uri)
      fetchFunderFieldData(result.item.id, closest_div)
    }
  });
});

function fetchFunderFieldData(funder_id, closest_div) {
  var host = window.document.location.host;
  var protocol = window.document.location.protocol;
  var fullHost = protocol + '//' + host + '/available_ubiquity_titles/call_funder_api';
  var closest_div = closest_div;
  closest_div.find('.ubiquity_funder_ror').val('')
  closest_div.find('.ubiquity_funder_isni').val('')
  $.ajax({
    url: fullHost,
    type: "POST",
    data: {"funder_id": funder_id},
    success: function(result){
      if (result.data.error  === undefined) {
        closest_div.find('.ubiquity_funder_ror').val(result.data.funder_ror)
        closest_div.find('.ubiquity_funder_isni').val(result.data.funder_isni)
      }
    }
  }) //closes $.ajax
}
