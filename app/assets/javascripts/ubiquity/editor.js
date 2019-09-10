// add linked fields

$(document).on("turbolinks:load", function(){
  var count = 1
  return $("body").on("click", ".add_editor", function(event){
    event.preventDefault();
    var ubiquityEditorClass = $(this).attr('data-addUbiquityEditor');
    var cloneUbiDiv = $(this).parent('div' + ubiquityEditorClass + ':last').clone();
    _this = this;
    cloneUbiDiv.find('input').val('');
    cloneUbiDiv.find('option').attr('selected', false);
    //increment hidden_field counter after cloning
    var lastInputCount = $('.ubiquity-editor-score:last').val();
    var hiddenInput = $(cloneUbiDiv).find('.ubiquity-editor-score');
    hiddenInput.val(parseInt(lastInputCount) + 1);
    $(ubiquityEditorClass +  ':last').after(cloneUbiDiv)
    $('.ubiquity_editor_name_type:last').val('Personal').change()
    removeDynamicallyAddedEditorClassNames();
    applyValidationRulesForField('editor');
  });
});

function removeDynamicallyAddedEditorClassNames (){
  var editor_fields = ["ubiquity_editor_name_type", "ubiquity_editor_isni", "ubiquity_editor_organization_name", "ubiquity_editor_orcid",
                        "ubiquity_editor_family_name", "ubiquity_editor_given_name"];
  $.each(editor_fields, function(index, value){
    removeClassStartingWith(value)
  });
  $.each(editor_fields, function(index, value){
    appendIndexToEachClasses(value);
  })
}

//remove linked fields
$(document).on("turbolinks:load", function(){
    return $("body").on("click", ".remove_editor", function(event){
        console.log('remove editor');
        event.preventDefault();
        var ubiquityEditorClass = $(this).attr('data-removeUbiquityEditor');

        _this = this;
        removeUbiquityEditor(_this, ubiquityEditorClass);

    });
});

function removeUbiquityEditor(self, editorDiv) {
    if ($(".ubiquity-meta-editor").length > 1 ) {
        $(self).parent('div' + editorDiv).remove();
    }
}

//for hiding and showing values on the edit form for editor sub fields
$(document).on("turbolinks:load", function(){
 return $("body").on("change",".ubiquity_editor_name_type", function(event){
   if (event.target.value == 'Personal') {
     $(this).siblings(".ubiquity_organization_fields:last").find(".ubiquity_editor_organization_name:last").val('')
     $(this).siblings(".ubiquity_organization_fields:last").hide();

     $(this).siblings(".ubiquity_editor_organization_name, .ubiquity_editor_organization_name_label").hide();
     $(this).siblings(".ubiquity_personal_fields").show();
   } else {

     $(this).siblings(".ubiquity_organization_fields:last").show();
     $(this).siblings(".ubiquity_personal_fields").find(".ubiquity_editor_family_name:last").val('');
     $(this).siblings(".ubiquity_personal_fields").find(".ubiquity_editor_given_name:last").val('');
     $(this).siblings(".ubiquity_personal_fields").find(".ubiquity_editor_orcid:last").val('');
     $(this).siblings(".ubiquity_personal_fields").find(".ubiquity_editor_institutional_relationship:last").val('');

    $(this).siblings(".ubiquity_personal_fields").hide();
    $(this).siblings(".ubiquity_editor_organization_name, .ubiquity_editor_organization_name_label").show();
   }
  });
});

$(document).on("turbolinks:load", function(){
 if($(".ubiquity_editor_name_type").is(':visible')){
  $(".ubiquity_editor_name_type").each(function() {
    //_this = this;
    displayeEditorFields(this);
  })
 };
});

$(document).on("turbolinks:load", function(){
 $('.additional-fields').click(function(event){
   $(".ubiquity_editor_name_type").each(function() {
     displayeEditorFields(this);
   })

 })
});


function displayeEditorFields(self) {
 if (self.value == 'Personal') {

   $(self).siblings(".ubiquity_organization_fields:last").find(".ubiquity_editor_organization_name:last").val('')
   $(self).siblings(".ubiquity_organization_fields:last").hide();

   $(self).siblings(".ubiquity_editor_organization_name, .ubiquity_editor_organization_name_label").hide();
   $(self).siblings(".ubiquity_personal_fields").show();
 } else if(self.value == "Organisational"){

   $(self).siblings(".ubiquity_organization_fields:last").show();
   $(self).siblings(".ubiquity_personal_fields").find(".ubiquity_editor_family_name:last").val('');
   $(self).siblings(".ubiquity_personal_fields").find(".ubiquity_editor_given_name:last").val('');
   $(self).siblings(".ubiquity_personal_fields").find(".ubiquity_editor_orcid:last").val('');
   $(self).siblings(".ubiquity_personal_fields").find(".ubiquity_editor_institutional_relationship:last").val('');

   $(self).siblings(".ubiquity_personal_fields").hide();
   $(self).siblings(".ubiquity_editor_organization_name, .ubiquity_editor_organization_name_label").show();
} else {
   $('.ubiquity_editor_name_type:last').val('Personal').change()
}
}
