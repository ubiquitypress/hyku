// Preselecting the value of Institution through JS, Please refer PreselectInstitutionHelper for the back end code
$(document).on("turbolinks:load", function(){
  if ($('.ubiquity-institution').length != 0){
    if ($('.ubiquity-institution:first').val() == ''){
      var institutionVal = $('#institution_selected_value').val();
      $('.ubiquity-institution:last').val(institutionVal);
    }
  }
});
