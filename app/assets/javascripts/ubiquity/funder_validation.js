$(document).on("turbolinks:load", function(){
  applyFunderValidationRulesForField();
});

// Trigger the validation when the document is ready
function applyFunderValidationRulesForField(){
  $('.ubiquity_funder_name').focusout(validateFunder);
  $('.ubiquity_funder_awards').focusout(validateFunder);
}

function validateFunder(event){
  var funder_name = $(event.target).parents('.ubiquity-meta-funder').find('.ubiquity_funder_name');
  var name_present = funder_name.val() != '';
  var award_present = $(event.target).parents('.ubiquity-meta-funder').find('.ubiquity_funder_awards').get().some(function(e) { return e.value != ''})

  if (award_present && !name_present){
    funder_name.prop('required', true);
    funder_name.css('border-color', 'red');
  } else {
    funder_name.prop('required', false);
    funder_name.css('border-color', '#ccc');
  }
}
