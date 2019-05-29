
  function messagesSwitcher(){
    var publicationYear = $('.ubiquity-date-published-year').val();
    var visibility = $('.set-access-controls ul.visibility li.radio input:checked').val();
    var doiOptions = $('ul.doi_option_list input:checked').val();
    var draftDoi = $(".ubiquity-draft-doi").val()
    var doi = $(".ubiquity-doi").val()
    var officialLink = $(".ubiquity-official-link").val()

    if (publicationYear == '') {
      var msg = 'Please go back and add a publication year, as this is required by DataCite.'
      $('#modal_button_save').attr('disabled', true);
    }
    else if ( officialLink !== '' && visibility == "embargo"){
      var msg = 'This work has a live DOI which will fail to lead to the work if you add an embargo. If you do continue, an updated record will be sent to DataCite on release of the embargo. '
      $('#modal_button_save').attr('disabled', false);
    }
    else if (doi !== ''){
      var msg = 'Please note an updated record will be sent to DataCite, if you continue.'
      $('#modal_button_save').attr('disabled', false);
    }
    else if (draftDoi !== '' && visibility == "embargo"){
      var msg = 'Please note that a DOI will be minted at DataCite on release of embargo, if you continue.'
      $('#modal_button_save').attr('disabled', false);
    }
    else if (draftDoi !== '' || publicationYear !== ''){
      var msg = 'Please note that a DOI will be minted at DataCite if you continue.'
      $('#modal_button_save').attr('disabled', false);
    }
    $('#modal_message').text(msg);
  }

  $(document).on("turbolinks:load", function(event){
    $('#with_files_submit').on('click', function(e) {
      messagesSwitcher();
      var visibility = $('.set-access-controls ul.visibility li.radio input:checked').val();
      var doiOptions = $('ul.doi_option_list input:checked').val();
      var visibilityCheck = (visibility == "open" || visibility == "embargo")
      var doiOptionsCheck = (doiOptions == "Mint DOI:Registered" || doiOptions == "Mint DOI:Findable")
      //conditions to be met to show modal window
      $("#doi-options-modal").on("click", "#modal_button_save", function() {
        $('#doi-options-modal').modal('hide');
        $('.simple_form').submit();
      });
      if (visibilityCheck && doiOptionsCheck) {
        $('#doi-options-modal').modal('show');
        e.preventDefault();
      }
    });
  });
