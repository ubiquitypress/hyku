// add linked fields

$(document).on("turbolinks:load", function(){
  return $("body").on("click", ".add_contributor", function(event){
    event.preventDefault();
    var ubiquityContributorClass = $(this).attr('data-addUbiquityContributor');
    cloneUbiDiv = $(this).parent('div' + ubiquityContributorClass + ':last').clone();

    _this = this;
    cloneUbiDiv.find('input').val('');
    cloneUbiDiv.find('option').attr('selected', false);
    //increment hidden_field counter after cloning
    var lastInputCount = $('.ubiquity-contributor-score:last').val();
    var hiddenInput = $(cloneUbiDiv).find('.ubiquity-contributor-score');
    hiddenInput.val(parseInt(lastInputCount) + 1)
    $(ubiquityContributorClass +  ':last').after(cloneUbiDiv);
    $('.ubiquity_contributor_name_type:last').val('Personal').change();
    removeDynamicallyAddedContributorClassNames();
    applyValidationRulesForField('contributor');
  });
});

function removeDynamicallyAddedContributorClassNames (){
  var contributor_fields = ["ubiquity_contributor_name_type", "ubiquity_contributor_isni", "ubiquity_contributor_organization_name", "ubiquity_contributor_orcid",
                        "ubiquity_contributor_family_name", "ubiquity_contributor_given_name"];
  $.each(contributor_fields, function(index, value){
    removeClassStartingWith(value)
  });
  $.each(contributor_fields, function(index, value){
    appendIndexToEachClasses(value);
  })
}

//remove linked fields
$(document).on("turbolinks:load", function(){
    return $("body").on("click", ".remove_contributor", function(event){
        event.preventDefault();
        var ubiquityContributorClass = $(this).attr('data-removeUbiquityContributor');

        _this = this;
        removeubiquityContributor(_this, ubiquityContributorClass);
    });
});

function removeubiquityContributor(self, contributorDiv) {
    if ($(".ubiquity-meta-contributor").length > 1 ) {
        $(self).parent('div' + contributorDiv).remove();
    }
}

//for hiding and showing values on the edit form for contributor sub fields
$(document).on("turbolinks:load", function(){
  return $("body").on("change",".ubiquity_contributor_name_type", function(event){
    if (event.target.value == 'Personal') {
      $(this).siblings(".ubiquity_organization_fields:last").find(".ubiquity_contributor_organization_name:last").val('')
      $(this).siblings(".ubiquity_organization_fields:last").hide();

      $(this).siblings(".ubiquity_contributor_organization_name, .ubiquity_contributor_organization_name_label").hide();
      $(this).siblings(".ubiquity_personal_fields").show();
    } else {

      $(this).siblings(".ubiquity_organization_fields:last").show();
      $(this).siblings(".ubiquity_personal_fields").find(".ubiquity_contributor_family_name:last").val('');
      $(this).siblings(".ubiquity_personal_fields").find(".ubiquity_contributor_given_name:last").val('');
      $(this).siblings(".ubiquity_personal_fields").find(".ubiquity_contributor_orcid:last").val('');
      $(this).siblings(".ubiquity_personal_fields").find(".ubiquity_contributor_institutional_relationship:last").val('');

     $(this).siblings(".ubiquity_personal_fields").hide();
     $(this).siblings(".ubiquity_contributor_organization_name, .ubiquity_contributor_organization_name_label").show();
    }
   });
});

$(document).on("turbolinks:load", function(){
  if($(".ubiquity_contributor_name_type").is(':visible')){
   $(".ubiquity_contributor_name_type").each(function() {
    // _this = this;
     displayContributorFields(this);

   })

  };
});

$(document).on("turbolinks:load", function(){
  $('.additional-fields').click(function(event){
    $(".ubiquity_contributor_name_type").each(function() {
      displayContributorFields(this);
    })

  })
});


function displayContributorFields(self){
  if (self.value == 'Personal') {

    $(self).siblings(".ubiquity_organization_fields:last").find(".ubiquity_contributor_organization_name:last").val('')
    $(self).siblings(".ubiquity_organization_fields:last").hide();

    $(self).siblings(".ubiquity_contributor_organization_name, .ubiquity_contributor_organization_name_label").hide();
    $(self).siblings(".ubiquity_personal_fields").show();
  } else if(self.value == "Organisational") {

    $(self).siblings(".ubiquity_organization_fields:last").show();
    $(self).siblings(".ubiquity_personal_fields").find(".ubiquity_contributor_family_name:last").val('');
    $(self).siblings(".ubiquity_personal_fields").find(".ubiquity_contributor_given_name:last").val('');
    $(self).siblings(".ubiquity_personal_fields").find(".ubiquity_contributor_orcid:last").val('');
    $(self).siblings(".ubiquity_personal_fields").find(".ubiquity_contributor_institutional_relationship:last").val('');


   $(self).siblings(".ubiquity_personal_fields").hide();
   $(self).siblings(".ubiquity_contributor_organization_name, .ubiquity_contributor_organization_name_label").show();
 } else {
   $('.ubiquity_contributor_name_type:last').val('Personal').change()
 }
}
