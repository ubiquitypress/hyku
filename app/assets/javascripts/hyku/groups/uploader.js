//= require hyrax/uploader

Blacklight.onLoad(function() {
  var options = {maxFileSize: 10737418240, maxChunkSize: 2000000};
  $('#fileupload').hyraxUploader(options);
  $('#fileupload').bind('fileuploadfail', function (e, data) {
    var filename = data.originalFiles[0].name
    $.ajax({
      type: 'GET',
      dataType: 'JSON',
      url: '/fail_uploads/delete_file',
      data:{
        file_upload: {
          filename: filename
        }
      }
    });
  });

  $('#with_files_submit').on('click', function(e) {
    var publicationYear = $('.ubiquity-date-published-year').val();
    var visibility = $('.set-access-controls ul.visibility li.radio input:checked').val();
    var doiOptions = $('ul.doi_option_list input:checked').val();
    var draftDoi = $(".ubiquity-draft-doi").val()
    var doi = $(".ubiquity-doi").val()

    if (publicationYear == '') {
      var msg = 'Please go back and add a publication year, as this is required by DataCite.'
      $('#modal_button_save').attr('disabled', true);
    }
    else if (doi !== '' && visibility == "embargo"){
      var msg = 'Please note that an updated record will be sent to DataCite on release of embargo, if you continue.'
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
    else if (draftDoi !== ''){
      var msg = 'Please note that a DOI will be minted at DataCite if you continue.'
      $('#modal_button_save').attr('disabled', false);
    }


    $('#modal_message').text(msg)
    var visibilityCheck = (visibility == "open" || visibility == "embargo")
    var doiOptionsCheck = (doiOptions == "Mint DOI:Registered" || doiOptions == "Mint DOI:Findable")

//conditions to be met to show modal window
      if (visibilityCheck && doiOptionsCheck) {
        $('#doi-options-modal').modal('show');
        e.preventDefault();
      }

  });
});
