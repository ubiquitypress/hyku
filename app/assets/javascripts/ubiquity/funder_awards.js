$(document).on("turbolinks:load", function(){
  $(document).on('click', ".add_another_funder_awards_button", function(e) { //on add input button click
    e.preventDefault();
    cloneElement = $(this).siblings('ul').find('li').last().clone();
    // Fetch and clone last funder award text field
    if (cloneElement.find('input').val() != '') {
      cloneElement.find('input').val('');
      cloneElement.find('a').remove();
      $(this).siblings('ul').find('div.message.has-funder-awards-warning').remove();
      cloneElement.append('<span class="input-group-btn"><a href="#" class="remove_funder_awards_field"><span class="glyphicon glyphicon-remove"></span>Remove Funder Awards</a></span>');
      $(this).parent('div').find('ul>li:last').last().after(cloneElement);
    }
    else{
      $(this).siblings('ul').find('div.message.has-funder-awards-warning').remove();
      divElement = '<div class="message has-funder-awards-warning">cannot add another with empty field</div>'
      $(this).parent('div').find('ul>li:last').last().after(divElement)
    }
  });

  $(document).on('click', ".remove_funder_awards_field", function(e) {
    e.preventDefault();
    $(this).siblings('ul').find('div.message.has-funder-awards-warning').remove();
    if ($(this).closest('li').parent('ul').children().length > 1 ) {
      $(this).closest('li').remove();
    }
  })
});
