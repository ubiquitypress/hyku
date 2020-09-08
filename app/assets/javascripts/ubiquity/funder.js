// add linked fields
$(document).on("turbolinks:load", function(){
  return $("body").on("click", ".add_funder", function(event){
    event.preventDefault();
    var ubiquityFunderClass = $(this).attr('data-addUbiquityFunder');
    cloneUbiDiv = $(this).parent('div' + ubiquityFunderClass + ':last').clone();

    _this = this;
    cloneUbiDiv.find('input').val('');
    cloneUbiDiv.find('ul li').not('li:first').remove();

    //increment hidden_field counter after cloning
    var lastInputCount = $('.ubiquity-funder-score:last').val();
    var hiddenInput = $(cloneUbiDiv).find('.ubiquity-funder-score');
    hiddenInput.val(parseInt(lastInputCount) + 1);
    $(ubiquityFunderClass +  ':last').after(cloneUbiDiv)
    activateAutocompleteForFunderName();
    applyFunderValidationRulesForField();
  });
});

//remove linked fields
$(document).on("turbolinks:load", function(){
  return $("body").on("click", ".remove_funder", function(event){
    event.preventDefault();
    var ubiquityFunderClass = $(this).attr('data-removeUbiquityFunder');
    _this = this;
    removeubiquityFunder(_this, ubiquityFunderClass);
  });
});

function removeubiquityFunder(self, funderDiv) {
  if ($(".ubiquity-meta-funder").length > 1 ) {
    $(self).parent('div' + funderDiv).remove();
  }
}

function activateAutocompleteForFunderName(){
  $(".ubiquity_funder_name").autocomplete({
    minLength: 2,
    source: function (request, response) {
      $.getJSON(this.element.data('autocomplete-url'), {
        q: request.term
      }, response );
    },
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
}
