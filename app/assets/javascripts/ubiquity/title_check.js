function checkTitle (ubiquityAlternativeTitleAry, ubiquityModel, ubiquityTitle) {
  var fullHost, host, protocol;
  host = window.document.location.host;
  protocol = window.document.location.protocol;
  fullHost = protocol + '//' + host + '/available_ubiquity_titles/check';
  $.ajax({
    url: fullHost,
    type: 'POST',
    data: {
      'title': ubiquityTitle,
      'model_class': ubiquityModel,
      'alternative_title': ubiquityAlternativeTitleAry
    },
    success: function(result) {
      if (result.data === 'true') {
        $('.ubiquity-title-fail-message').html(result.message + result.title_list);
        $('.ubiquity-title-fail-message').show();
      } else {
        $('.ubiquity-title-success-message').html(result.message);
        $('.ubiquity-title-success-message').show();
      }
    },
    error: function() {}
  });
  };

  $(document).on('turbolinks:load', function() {
  $('.ubiquity-title-checker').click(function(event) {
    var ubiquityModel, ubiquityAlternativeTitleAry, ubiquityTitle;
    event.preventDefault();
    $('.ubiquity-title-success-message').hide();
    $('.ubiquity-title-fail-message').hide();
    ubiquityModel = $(this).attr('data-ubiquity-model');
    ubiquityTitle = $(".ubiquity-title").val();
    ubiquityAlternativeTitleAry = $('.ubiquity-alternative-title').map(function() {
      return $(this).val();
    }).get();
    if (ubiquityAlternativeTitleAry.length !== 0) {
      checkTitle(ubiquityAlternativeTitleAry, ubiquityModel, ubiquityTitle);
    }
  });
});
