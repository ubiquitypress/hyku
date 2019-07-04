//= require hyrax/uploader

Blacklight.onLoad(function() {
  var options = {maxFileSize: 10737418240, maxChunkSize: 10000000, maxRetries: 7, retryTimeout: 5000};
  $('#fileupload').hyraxUploader(options);
  $('#fileupload').bind('fileuploadfail', function (e, data) {
    var filename = data.originalFiles[0].name;
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
});
