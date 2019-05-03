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
  console.log('thisis loading');
  $('#with_files_submit').on('click', function(e) {
    var publicationYear = $('#date_year').val();
    var publicationMonth = $('#date_month').val();
    var publicationDay = $('#date_day').val();
    var date = new Date(publicationYear + '-' + publicationMonth + '-' + publicationDay);
    if (date instanceof Date) {
      var msg = 'Please note that a DOI will be minted at DataCite if you continue (or an updated record will be sent to DataCite) - if your work is under embargo, then the record will be sent to DataCite on release of the embargo'
      $('#modal_button_save').attr('disabled', false);
    }
    else {
      var msg = 'Please go back and add a publication year, as this is required by DataCite'
      $('#modal_button_save').attr('disabled', true);
    }
    $('#modal_message').text(msg)
    $('#myModal').modal('show');

    console.log('preventing Submitted');
    e.preventDefault();
  });
});
