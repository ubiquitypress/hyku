// The below code it is used to remove the "workflow-affix" class from the approval form on the show page
// so the widget doesn't appear on the footer

$(document).on("turbolinks:load", function(){
  $(".workflow-affix").removeClass( "workflow-affix" )
  //Hide these sharing  buttons
  $('a[title="Google+"]').hide()
  $('a[title="Tumblr"]').hide()
})

$(document).on("turbolinks:load", function() {
  var pathName = window.location.pathname;

  if (pathName.includes("new")  ) {
    $('.ubiquity-admin-set').val('admin_set/default');
    $('.set-access-controls ul.visibility li.radio input').prop("disabled", false);
    //sets default radio button selection to restricted or private.
    $('.set-access-controls ul.visibility li.radio input').last().prop("checked", true);
  }

})
