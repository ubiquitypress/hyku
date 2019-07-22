$(document).on("turbolinks:load", function(){
  var editor_fields = ["ubiquity_editor_name_type", "ubiquity_editor_isni", "ubiquity_editor_organization_name", "ubiquity_editor_orcid",
                        "ubiquity_editor_family_name", "ubiquity_editor_given_name"];
  var creator_fields = ["ubiquity_creator_name_type", "ubiquity_creator_isni", "ubiquity_creator_organization_name", "ubiquity_creator_orcid",
                        "ubiquity_creator_family_name", "ubiquity_creator_given_name"];
  var contributor_fields = ["ubiquity_contributor_name_type", "ubiquity_contributor_isni", "ubiquity_contributor_organization_name", "ubiquity_contributor_orcid",
                        "ubiquity_contributor_family_name", "ubiquity_contributor_given_name"];
  $.each(editor_fields, function(_index, value){
    appendIndexToEachClasses(value);
  });

  $.each(creator_fields, function(_index, value){
    appendIndexToEachClasses(value);
  });

  $.each(contributor_fields, function(_index, value){
    appendIndexToEachClasses(value);
  });

  applyValidationRulesForField('creator');
  applyValidationRulesForField('contributor');
  applyValidationRulesForField('editor');
  // triggerValidationIfValueIsPresent();
});

function triggerValidationIfValueIsPresent(){
  var value_check_fields = ['ubiquity_editor_isni', 'ubiquity_creator_isni', 'ubiquity_contributor_isni'];
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

function removeClassStartingWith(classNameVal) {
  $('.'+classNameVal).removeClass (function (index, className) {
    return (className.match ( new RegExp("\\b"+classNameVal+'_x'+"\\S+", "g") ) || []).join(' ');
  });
}

function applyValidationRulesForField(field){
  var ary_length = $('.ubiquity_'+field+'_isni').length;
  for(var n = 1; n <= ary_length; n++){
    checkForPresenceOfOrcidValue(field, n);
    validationBasedOnPersonalFieldNames(field, n);
    validationBasedOnOrganisationalFieldNames(field, n)
    validationBasedOnNameType(field, n);
  }
}

function checkForPresenceOfOrcidValue(field, index){
  $('.ubiquity_'+field+'_orcid_x'+index+', .ubiquity_'+field+'_isni_x'+index).focusout(function(){
    var check_for_name = ($('.ubiquity_'+field+'_orcid_x'+index).val() != '') || ($('.ubiquity_'+field+'_isni_x'+ index).val() != '');
    var drop_down_val = $('.ubiquity_'+field+'_name_type_x'+index).val();
    var check_for_isni_value = $('.ubiquity_'+field+'_isni_x'+index).val();
    var check_for_org_value = $('.ubiquity_'+field+'_organization_name_x'+index).val();
    if ((drop_down_val == 'Organisational') && (check_for_org_value == '') && (check_for_isni_value != '')) {
      addOrganisationNameMandatory(field, index);
    }
    else if (check_for_name) {
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
}

function addFieldsNamesMandatory(field, index) {
  $('.ubiquity_'+field+'_family_name_x'+index).prop('required', true);
  $('.ubiquity_'+field+'_family_name_x'+index).css('border-color', 'red');
  $('.ubiquity_'+field+'_given_name_x'+index).prop('required', true);
  $('.ubiquity_'+field+'_given_name_x'+index).css('border-color', 'red');
  $('.ubiquity_'+field+'_organization_name_x'+index).prop('required', true);
  $('.ubiquity_'+field+'_organization_name_x'+index).css('border-color', 'red');
}

function addFieldsNamesMandatoryForPersonalFields(field, index){
  $('.ubiquity_'+field+'_family_name_x'+index).prop('required', true);
  $('.ubiquity_'+field+'_family_name_x'+index).css('border-color', 'red');
  $('.ubiquity_'+field+'_given_name_x'+index).prop('required', true);
  $('.ubiquity_'+field+'_given_name_x'+index).css('border-color', 'red');
}

function addOrganisationNameMandatory(field, index){
  $('.ubiquity_'+field+'_organization_name_x'+index).prop('required', true);
  $('.ubiquity_'+field+'_organization_name_x'+index).css('border-color', 'red');
}