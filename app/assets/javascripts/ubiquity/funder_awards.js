$(document).on("turbolinks:load", function(){
	var add_button = $(".add_funder_awards_field_button");
	var funder_awards_wrapper = $('ul.funder_awards_input_fields_wrap')

	$(add_button).click(function(e){ //on add input button click
		e.preventDefault();
		// Fetch and clone last funder award text field
		cloneElement = funder_awards_wrapper.find('li:last').clone();
		cloneElement.find('input').val('');
		cloneElement.appendTo(funder_awards_wrapper).append('<a href="#" class="remove_funder_awards_field">Remove</a>');
	});

	$(funder_awards_wrapper).on("click",".remove_funder_awards_field", function(e){ //user click on remove text
    e.preventDefault();
    if ($("ul.funder_awards_input_fields_wrap li").length > 1 ) {
      $(this).closest('li').remove();
    }
	})
});
