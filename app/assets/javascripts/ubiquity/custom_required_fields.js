// The script enabled the Institution and Journal Title mandatory, Because of the re-ordering issue
// We removed these fields as required from the back end and made it required via JS

$(document).on("turbolinks:load", function(){
  var ubiquityModel = $('.ubiquity-title-checker').data('ubiquity-model')
  if (($('.ubiquity-journal-title').length != 0) && (ubiquityModel === 'Article')) {
    $('.ubiquity-journal-title').prop('required', true)
    appendRequiredTagToLabel($('.ubiquity-journal-title').attr('id'))
  }
  if (($('.ubiquity-qualification-name').length != 0) && (ubiquityModel === 'ThesisOrDissertation')) {
    $('.ubiquity-qualification-name').prop('required', true)
    appendRequiredTagToLabel($('.ubiquity-qualification-name').attr('id'))
  }
  if (($('.ubiquity-qualification-level').length != 0) && (ubiquityModel === 'ThesisOrDissertation')) {
    $('.ubiquity-qualification-level').prop('required', true)
    appendRequiredTagToLabel($('.ubiquity-qualification-level').attr('id'))
  }
  if ($('.ubiquity-institution').length != 0){
    if ($('.ubiquity-institution:first').val() == ''){
      $('.ubiquity-institution').prop('required', true)
    }
    appendRequiredTagToLabel($('.ubiquity-institution').attr('id'))
  }
  if ($('.resource-type').length != 0){
    if ($('.resource-type').val() == ''){
      $('.resource-type').prop('required', true)
    }
    appendRequiredTagToLabel($('.resource-type').attr('id'))
  }

  $('#with_files_submit').on('click', function(e) {
    if ($('.ubiquity-institution:first').val() == ''){
      $('.ubiquity-institution').prop('required', true)
    }
  });

  // Setting the defaut admin set value for the Administrative Set
  $('.ubiquity-admin-set').val('admin_set/default');
});

// This method appends the 'Required' tag in the label of the corresponding field

function appendRequiredTagToLabel(labelForTag){
  $("label[for=" + labelForTag +"]").append('  <span class="label label-info required-tag">required</span>')
}
