//= require hyrax/uploader
Blacklight.onLoad(function() {
  var options = {maxFileSize: 10737418240};
  $('#fileupload').hyraxUploader(options);
});