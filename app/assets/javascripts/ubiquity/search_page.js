//to reproduce from homepage, click on 'view all collections',
//the text shown in the filter is "Human readable type sim > Collection"
// this code changes Collection to Collections so we get "Human readable type sim > Collections"
$(document).on("turbolinks:load", function(){
  if($(".filter-human_readable_type_sim").is(':visible')){
    var span = $('.filter-human_readable_type_sim').find('span.filterValue');
    span.attr('title','Collections')
    return span.html('Collections');
  }
});
