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
    var date = new Date(publicationYear + '-' + publicationMonth + '-' + publicationDay)
    if (date == 'Valid Date') //check for public visibility and embargo {
      var msg = 'Message in the case of publication year is Not blank'
      $('#modal_button_save').attr('disabled', false);
    }
    else {
      var msg = 'hi this is condition when the published Date  is blank'
      $('#modal_button_save').attr('disabled', true);
    }
    $('#modal_message').text(msg)
    $('#myModal').modal('show');

    console.log('preventing Submitted');
    e.preventDefault();
  });
});
