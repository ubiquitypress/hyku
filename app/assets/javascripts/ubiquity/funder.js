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
