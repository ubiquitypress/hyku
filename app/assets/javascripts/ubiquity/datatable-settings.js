$(document).on("turbolinks:load", function(event){
  var dataTable = $('.collection-table-datatable').DataTable({
    "columnDefs": [
      { "targets":["no-sort"], "orderable": false, "searchable": false },
      { type: 'non-empty-string', targets: 3 }
    ],
    order: [[ 1, "asc" ]]
  });

  var totalCount = dataTable.rows().count();
  $('#total_count_div').text(totalCount);

  jQuery.extend( jQuery.fn.dataTableExt.oSort, {
    "non-empty-string-asc": function (str1, str2) {
      var str1 = $(str1).text().trim();
      var str2 = $(str2).text().trim();
      if(str1 == "")
        return 1;
      if(str2 == "")
        return -1;
      if(str1.length > str2.length & str1.slice(0,str2.length) === str2)
        return 1
      if(str2.length > str1.length & str2.slice(0,str1.length) === str1)
        return -1

      return ((str1 < str2) ? -1 : ((str1 > str2) ? 1 : 0));
    },

    "non-empty-string-desc": function (str1, str2) {
      var str1 = $(str1).text().trim();
      var str2 = $(str2).text().trim();
      if(str1 == "")
        return 1;
      if(str2 == "")
        return -1;
      if(str1.length > str2.length & str1.slice(0,str2.length) === str2)
        return 1
      if(str2.length > str1.length & str2.slice(0,str1.length) === str1)
        return -1

      return ((str1 < str2) ? 1 : ((str1 > str2) ? -1 : 0));
    }
  });

  // https://github.com/mkhairi/jquery-datatables/issues/8
  document.addEventListener("turbolinks:before-cache", function() {
    if (dataTable !== null) {
    dataTable.destroy();
    dataTable = null;
    }
  });

  $('.collection-table-datatable').on('click', 'td.details-control', function () {
    var tr = $(this).closest('tr');
    var row = dataTable.row(tr);
    if (row.child.isShown()) {
      // This row is already open - close it
      row.child.hide();
      tr.removeClass('shown');
    } else {
      // Open this row
      row.child(tr.data('child-value')).show();
      tr.addClass('shown');
    }
  });
});
