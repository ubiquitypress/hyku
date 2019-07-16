$(document).on("turbolinks:load", function(){
  $('.ubiquity_creator_orcid, .ubiquity_creator_isni').focusout(function(){
    var check_for_name = ($('.ubiquity_creator_orcid').val() != '') || ($('.ubiquity_creator_isni').val() != '');
    var drop_down_val = $('.ubiquity_creator_name_type').val();
    var check_for_isni_value = $('.ubiquity_creator_isni').val();
    var check_for_org_value = $('.ubiquity_creator_organisation_name_text_field').val();
    if ((drop_down_val == 'Organisational') && (check_for_org_value == '') && (check_for_isni_value != '')) {
      addOrganisationNameMandatory()
    }
    else if (check_for_name) {
      var check_for_value = ($('.ubiquity_creator_family_name').val() != '') || ($('.ubiquity_creator_given_name').val() != '')
      if (check_for_value == false){
        addFieldsNamesMandatory()
      }
    }
    else{
      removeFieldsNamesFromMandatory()
    }
  })

  $('.ubiquity_creator_family_name, .ubiquity_creator_given_name, .ubiquity_creator_organisation_name_text_field').focusout(function(){
    if (($('.ubiquity_creator_given_name').val() != '') && $('.ubiquity_creator_given_name').is(":visible")) {
      removeFieldsNamesFromMandatory()
    }
    else if (($('.ubiquity_creator_family_name').val() != '') && $('.ubiquity_creator_family_name').is(":visible")) {
      removeFieldsNamesFromMandatory()
    }
    else if (($('.ubiquity_creator_organisation_name_text_field').val() != '') && $('.ubiquity_creator_organisation_name_text_field').is(":visible")) {
      removeFieldsNamesFromMandatory()
    }
    else if (($('.ubiquity_creator_orcid').val() != '') || ($('.ubiquity_creator_isni').val() != '')) {
      addFieldsNamesMandatory()
    }
  })

  $('.ubiquity_creator_name_type').change(function(){
    // When it changes the drop down value of the creater type
    $('.ubiquity_creator_orcid').trigger('focusout');
    if (this.value == 'Personal') {
      var check_for_name = ($('.ubiquity_creator_given_name').val() != '') || ($('.ubiquity_creator_family_name').val() != '');
      if ($('.ubiquity_creator_isni').val() != '' && check_for_name == false) {
        addFieldsNamesMandatory()
      }
      else{
        removeFieldsNamesFromMandatory();
      }
    }
    else{
      var check_for_org_value = $('.ubiquity_creator_organisation_name_text_field').val();
      if ($('.ubiquity_creator_isni').val() != '' && check_for_org_value == '') {
        addFieldsNamesMandatory();
      }
      else{
        removeFieldsNamesFromMandatory();
      }
    }
  });

});

function removeFieldsNamesFromMandatory() {
  $('.ubiquity_creator_family_name').prop('required', false)
  $('.ubiquity_creator_family_name').css('border-color', '#ccc')
  $('.ubiquity_creator_given_name').prop('required', false)
  $('.ubiquity_creator_given_name').css('border-color', '#ccc')
  $('.ubiquity_creator_organisation_name_text_field').prop('required', false)
  $('.ubiquity_creator_organisation_name_text_field').css('border-color', '#ccc')
}

function addFieldsNamesMandatory() {
  $('.ubiquity_creator_family_name').prop('required', true)
  $('.ubiquity_creator_family_name').css('border-color', 'red')
  $('.ubiquity_creator_given_name').prop('required', true)
  $('.ubiquity_creator_given_name').css('border-color', 'red')
  $('.ubiquity_creator_organisation_name_text_field').prop('required', true)
  $('.ubiquity_creator_organisation_name_text_field').css('border-color', 'red')
}

function addOrganisationNameMandatory(){
  $('.ubiquity_creator_organisation_name_text_field').prop('required', true)
  $('.ubiquity_creator_organisation_name_text_field').css('border-color', 'red')
}