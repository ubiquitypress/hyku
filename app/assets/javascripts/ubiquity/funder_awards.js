$(document).on("turbolinks:load", function(){
    var add_button = $(".add_funder_awards_field_button");
    var funder_awards_wrapper = $('.funder_awards_input_fields_wrap')

	$(add_button).click(function(e){ //on add input button click
    e.preventDefault();
    // Fetch and clone last funder award text field
    cloneUbiDiv = $('.ubiquity_funder_awards :last').clone();
    cloneUbiDiv.find('input').val('');
    $('.ubiquity_funder_awards :last').after(cloneUbiDiv)
    $('.ubiquity_funder_awards :last').append('<a href="#" class="remove_funder_awards_field">Remove</a></div>')
	});

	$(funder_awards_wrapper).on("click",".remove_funder_awards_field", function(e){ //user click on remove text
    e.preventDefault();
    if ($(".ubiquity_funder_awards").length > 1 ) {
      $(this).parent('div').remove();
    }
	})
});
