$(document).on("turbolinks:load", function(){
	var add_button      = $(".add_funder_awards_field_button");

	$(add_button).click(function(e){ //on add input button click
    e.preventDefault();
    // Fetch and clone last funder award text field
    var ubiquityFunderAwardsClass = $(this).attr('data-ubiquity_funder_awards');
    cloneUbiDiv = $(this).parent('div' + ubiquityFunderAwardsClass + ':last').clone();
    _this = this;
    cloneUbiDiv.find('input').val('');
    $(ubiquityFunderAwardsClass +  ':last').after(cloneUbiDiv)
    $(ubiquityFunderAwardsClass +  ':last').append('<a href="#" class="remove_funder_field">Remove</a></div>')
	});

	$(wrapper).on("click",".remove_funder_field", function(e){ //user click on remove text
		e.preventDefault(); $(this).parent('div').remove();
	})
});
