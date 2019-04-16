//= require hyrax/uploader
Blacklight.onLoad(function() {
  var options = {maxFileSize: 5368709120, recalculateProgress: true, multipart: true};
  $('#fileupload').hyraxUploader(options)
  $('#fileupload').bind('fileuploadprogressall', function (e, data) {
    var percentage = (data.loaded / data.total * 100).toFixed(2)
    // $progressBar.css({width: percentage + '%'})
    Math.round((data.loaded * 100) / data.total);
    console.log(data.loaded, data.total, percentage + '%')
  });
});