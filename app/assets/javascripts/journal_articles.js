

/*
// add linked fields

$(document).on("turbolinks:load", function(){

    return $("body").on("click", ".add_contributor", function(event){
        alert('me');
        console.log('add contribuor');

      event.preventDefault();
      var ubiquityContributorClass = $(this).attr('data-addUbiquityContributor');
      var time = new Date().getTime();
      cloneUbiDiv = $(this).parent('div' + `${ubiquityContributorClass}`).clone();
      $(`${ubiquityContributorClass}` +  ':last').after(cloneUbiDiv)

    });
});


  //remove linked fields
    $(document).on("turbolinks:load", function(){
    //$(document).ready(function() {
        return $("body").on("click", ".remove_contributor", function(event){
            console.log('remove contribuor');
            event.preventDefault();
            var ubiquityContributorClass = $(this).attr('data-removeUbiquityContributor');

            $(this).parent('div' + `${ubiquityContributorClass}`).not(':first').remove();
        });
    });


    */