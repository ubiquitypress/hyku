// The below code it is used to remove the "workflow-affix" class from the approval form on the show page
// so the widget doesn't appear on the footer

$(document).on("turbolinks:load", function(){
  $(".workflow-affix").removeClass( "workflow-affix" )
})
