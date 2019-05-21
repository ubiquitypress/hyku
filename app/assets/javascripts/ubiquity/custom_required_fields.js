// The script enabled the Institution and Journal Title mandatory, Because of the re-ordering issue
// We removed these fields as required from the back end and made it required via JS

$(document).on("turbolinks:load", function(){
  if ($('.ubiquity-journal-title').length != 0){
    $('.ubiquity-journal-title').prop('required', true)
    appendRequiredTagToLabel($('.ubiquity-journal-title').attr('id'))
  }
  if ($('.ubiquity-institution').length != 0){
    if ($('.ubiquity-institution:first').val() == ''){
      $('.ubiquity-institution').prop('required', true)
    }
    appendRequiredTagToLabel($('.ubiquity-institution').attr('id'))
  }

  $('#with_files_submit').on('click', function(e) {
    if ($('.ubiquity-institution:first').val() == ''){
      $('.ubiquity-institution').prop('required', true)
    }
  });
});

// This method appends the 'Required' tag in the label of the corresponding field

function appendRequiredTagToLabel(labelForTag){
  $("label[for=" + labelForTag +"]").append('  <span class="label label-info required-tag">required</span>')
}
