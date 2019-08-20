//to reproduce from homepage, click on 'view all collections',
//the text shown in the filter is "Human readable type sim > Collection"
// this code changes Collection to Collections so we get "Human readable type sim > Collections"
$(document).on("turbolinks:load", function(){
  if($(".filter-human_readable_type_sim").is(':visible')){
    var spanFilterValue = $('.filter-human_readable_type_sim').find('span.filterValue');
    var spanFilterName = $('.filter-human_readable_type_sim').find('span.filterName');
    spanFilterValue.attr('title','Collections');
    spanFilterName.hide();
    spanFilterValue.html('Collections');
  }

 //clear all search filters fails by linking to the wrong page
 // we are adding this query parameter &search_field=all_fields
  if($("#appliedParams .pull-right").is(':visible')){
    return  $(this).find("a").attr('href', '/catalog?locale=en&q=&search_field=all_fields')
  }
});
