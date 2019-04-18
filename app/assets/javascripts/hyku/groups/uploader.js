//= require hyrax/uploader

Blacklight.onLoad(function() {
  var options = {maxFileSize: 5368709120, maxChunkSize: 1000000};
  $('#fileupload').hyraxUploader(options);
});