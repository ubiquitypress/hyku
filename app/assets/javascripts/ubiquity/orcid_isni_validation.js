$(document).on("turbolinks:load", function(){
  // Fetching Text Fileds across multiple fields
  var editor_fields = ["ubiquity_editor_name_type", "ubiquity_editor_isni", "ubiquity_editor_organization_name", "ubiquity_editor_orcid",
                        "ubiquity_editor_family_name", "ubiquity_editor_given_name"];

  var contributor_fields = ["ubiquity_contributor_name_type", "ubiquity_contributor_isni", "ubiquity_contributor_organization_name", "ubiquity_contributor_orcid",
                        "ubiquity_contributor_family_name", "ubiquity_contributor_given_name"];

  // Adding index to each fields eg ending with x1, x2 based on adding new field by the user
  $.each(editor_fields, function(_index, value){
    appendIndexToEachClasses(value);
  });

  $.each(contributor_fields, function(_index, value){
    appendIndexToEachClasses(value);
  });

  // This will trigger the validation based on the type of field (Creator, Editor and Contributor)
  applyValidationRulesForField('contributor');
  applyValidationRulesForField('editor');
  // triggerValidationIfValueIsPresent(); //Keeping it for future based on feedback from client
});

// Currently not using but keeping it in future to trigger validation for existing records
function triggerValidationIfValueIsPresent(){
  var value_check_fields = ['ubiquity_editor_isni', 'ubiquity_contributor_isni'];
  $.each(value_check_fields, function(_index, field_element){
    triggerValidation(field_element);
  });
}

function triggerValidation(elementClassName){
  $('.'+elementClassName).each(function (i) {
    if ($(this).val != ''){
      $(this).trigger('focusout');
    }
  });
}

function appendIndexToEachClasses(className) {
  $('.'+className).each(function (i) {
    var name = $(this).data("fieldName") + '_x'+ (i+1);
    $(this).addClass(name);
  });
}

// Called from the view of each contributor_js, creator_js file -> Triggered when the user add another field for any of the fields.
function removeClassStartingWith(classNameVal) {
  $('.'+classNameVal).removeClass (function (index, className) {
    return (className.match ( new RegExp("\\b"+classNameVal+'_x'+"\\S+", "g") ) || []).join(' ');
  });
}

// Trigger the validation whne the document is ready
function applyValidationRulesForField(field){
  var ary_length = $('.ubiquity_'+field+'_isni').length;
  for(var n = 1; n <= ary_length; n++){
    checkForPresenceOfOrcidValue(field, n);
    validationBasedOnPersonalFieldNames(field, n);
    validationBasedOnOrganisationalFieldNames(field, n)
    validationBasedOnNameType(field, n);
  }
}

// Checking the presence of ORCID or ISNI value in the text field for Creator, Editor and Contributor
function checkForPresenceOfOrcidValue(field, index){
  $('.ubiquity_'+field+'_orcid_x'+index+', .ubiquity_'+field+'_isni_x'+index).focusout(function(){
    var check_for_name = ($('.ubiquity_'+field+'_orcid_x'+index).val() != '') || ($('.ubiquity_'+field+'_isni_x'+ index).val() != '');
    var drop_down_val = $('.ubiquity_'+field+'_name_type_x'+index).val();
    var check_for_isni_value = $('.ubiquity_'+field+'_isni_x'+index).val();
    var check_for_org_value = $('.ubiquity_'+field+'_organization_name_x'+index).val();
    if ((drop_down_val == 'Organisational') && (check_for_org_value == '') && (check_for_isni_value != '')) {
      addOrganisationNameMandatory(field, index);
    }
    else if ((drop_down_val == 'Personal') && check_for_name) {
      var check_for_value = ($('.ubiquity_'+field+'_family_name_x'+ index).val() != '') || ($('.ubiquity_'+field+'_given_name_x'+index).val() != '');
      if (check_for_value == false){
        addFieldsNamesMandatoryForPersonalFields(field, index);
      }
    }
    else{
      removeFieldsNamesFromMandatory(field, index);
    }
  });
}

// Validation for the Personal Field seletion for namwe type
function validationBasedOnPersonalFieldNames(field, index){
  $('.ubiquity_'+field+'_family_name_x'+index+', .ubiquity_'+field+'_given_name_x'+index).focusout(function(){
    var check_for_name = ($('.ubiquity_'+field+'_orcid_x'+index).val() != '') || ($('.ubiquity_'+field+'_isni_x'+ index).val() != '');
    if (check_for_name){
      var check_for_value = ($('.ubiquity_'+field+'_family_name_x'+ index).val() != '') || ($('.ubiquity_'+field+'_given_name_x'+index).val() != '');
      if (check_for_value == false){
        addFieldsNamesMandatoryForPersonalFields(field, index);
      }
      else{
        removeFieldsNamesFromMandatory(field, index);
      }
    }
  });
}

// Validation for the Organisation field
function validationBasedOnOrganisationalFieldNames(field, index){
  $('.ubiquity_'+field+'_organization_name_x'+index).focusout(function(){
    var check_for_isni_value = $('.ubiquity_'+field+'_isni_x'+index).val();
    var check_for_org_value = $('.ubiquity_'+field+'_organization_name_x'+index).val();
    if ((check_for_org_value == '') && (check_for_isni_value != '')){
      addOrganisationNameMandatory(field, index);
    }
    else{
      removeFieldsNamesFromMandatory(field, index);
    }
  });
}

// Validation based on the drop down selection of the name type for creator, editor and contributor
function validationBasedOnNameType(field, index) {
  $('.ubiquity_'+field+'_name_type_x'+index).change(function(){
    // When it changes the drop down value of the field type type
    $('.ubiquity_'+field+'_orcid_x'+index).trigger('focusout');
    if (this.value == 'Personal') {
      var check_for_name = ($('.ubiquity_'+field+'_given_name_x'+index).val() != '') || ($('.ubiquity_'+field+'_family_name_x'+index).val() != '');
      if ($('.ubiquity_'+field+'_isni_x'+index).val() != '' && check_for_name == false) {
        addFieldsNamesMandatoryForPersonalFields(field, index);
      }
      else{
        removeFieldsNamesFromMandatory(field, index);
      }
    }
    else{
      var check_for_org_value = $('.ubiquity_'+field+'_organization_name_x'+index).val();
      if ($('.ubiquity_'+field+'_isni_x'+index).val() != '' && check_for_org_value == '') {
        addOrganisationNameMandatory(field, index);
      }
      else{
        removeFieldsNamesFromMandatory(field, index);
      }
    }
  });
}


function removeFieldsNamesFromMandatory(field, index) {
  $('.ubiquity_'+field+'_family_name_x'+index).prop('required', false)
  $('.ubiquity_'+field+'_family_name_x'+index).css('border-color', '#ccc');
  $('.ubiquity_'+field+'_given_name_x'+index).prop('required', false);
  $('.ubiquity_'+field+'_given_name_x'+index).css('border-color', '#ccc');
  $('.ubiquity_'+field+'_organization_name_x'+index).prop('required', false);
  $('.ubiquity_'+field+'_organization_name_x'+index).css('border-color', '#ccc');
  // Remove message near to the text field
  $('.ubiquity_'+field+'_organization_name_x'+index).next('span.error').remove();
  $('.ubiquity_'+field+'_given_name_x'+index).next('span.error').remove();
  $('.ubiquity_'+field+'_family_name_x'+index).next('span.error').remove();
}

function addFieldsNamesMandatoryForPersonalFields(field, index){
  // Family Name
  $('.ubiquity_'+field+'_family_name_x'+index).prop('required', true);
  $('.ubiquity_'+field+'_family_name_x'+index).css('border-color', 'red');
  if ($('.ubiquity_'+field+'_family_name_x'+index).next('span.error').length == 0){
    $('.ubiquity_'+field+'_family_name_x'+index).after('<span class="error">Please enter one of these fields.</span>');
  }
  // Given Name
  $('.ubiquity_'+field+'_given_name_x'+index).prop('required', true);
  $('.ubiquity_'+field+'_given_name_x'+index).css('border-color', 'red');
  if ($('.ubiquity_'+field+'_given_name_x'+index).next('span.error').length == 0){
    $('.ubiquity_'+field+'_given_name_x'+index).after('<span class="error">Please enter one of these fields.</span>');
  }
}

function addOrganisationNameMandatory(field, index){
  $('.ubiquity_'+field+'_organization_name_x'+index).prop('required', true);
  $('.ubiquity_'+field+'_organization_name_x'+index).css('border-color', 'red');
  if ($('.ubiquity_'+field+'_organization_name_x'+index).next('span.error').length == 0){
    $('.ubiquity_'+field+'_organization_name_x'+index).after('<span class="error">Please enter the required field.</span>');
  }
}
