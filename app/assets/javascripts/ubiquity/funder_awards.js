$(document).on("turbolinks:load", function(){
  $(document).on('click', ".add_another_funder_awards_button", function(e) { //on add input button click
    e.preventDefault();
    cloneElement = $(this).siblings('ul').find('li').last().clone();
    // Fetch and clone last funder award text field
    if (cloneElement.find('input').val() != '') {
      cloneElement.find('input').val('');
      cloneElement.find('span.input-group-btn').remove();
      cloneElement.removeAttr('style');
      $(this).siblings('ul').find('div.message.has-funder-awards-warning').remove();
      cloneElement.append('<span class="input-group-btn field-controls"><a href="#" style="color:red;" class="remove_funder_awards_field btn"><span class="glyphicon glyphicon-remove"></span>Remove</a></span>');
      $(this).parent('div').find('ul>li:last').last().after(cloneElement);
    }
    else{
      $(this).siblings('ul').find('div.message.has-funder-awards-warning').remove();
      divElement = '<div class="message has-funder-awards-warning has-warning">cannot add another with empty field</div>'
      $(this).parent('div').find('ul>li:last').last().after(divElement)
    }
    applyFunderValidationRulesForField();
  });

  $(document).on('click', ".remove_funder_awards_field", function(e) {
    e.preventDefault();
    $(this).siblings('ul').find('div.message.has-funder-awards-warning').remove();
    if ($(this).closest('li').parent('ul').children().length > 1 ) {
      $(this).closest('li').remove();
    }
  })

  $('ul.funder_awards_input_fields_wrap').each(function(index){
    $(this).find('li').each(function(index){
      if (index === 0) {
        var remove_button = $('<span class="input-group-btn field-controls"><a href="#" class="remove_funder_awards_field btn"></a></span>')
        $(this).css('padding-right', '67px');
      }
      else{
        var remove_button = $('<span class="input-group-btn field-controls"><a href="#" style="color:red;" class="remove_funder_awards_field btn"><span class="glyphicon glyphicon-remove"></span>Remove</a></span>')
      }
      $(this).append(remove_button);
    })
  })
});
