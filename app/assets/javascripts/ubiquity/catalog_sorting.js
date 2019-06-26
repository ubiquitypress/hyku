$(document).on("turbolinks:load", function(){
  $('ol.catalog li').each(function(){
    var published_date = $(this).find('td.published-date-td').text();
    $(this).attr('data-sort', published_date);
  });
  var myArray = $('ol.catalog li')
  var sort_order = $('#sort_order').val()

  if (sort_order == 'asc') {
    myArray.sort(function (a, b) {

      var str1 = $(a).data("sort").toString();
      var str2 = $(b).data("sort").toString();
      if(str1 == "")
        return 1;
      if(str2 == "")
        return -1;
      if(str1.length > str2.length & str1.slice(0,str2.length) === str2)
        return -1
      if(str2.length > str1.length & str2.slice(0,str1.length) === str1)
        return 1
      return ((str1 < str2) ? -1 : ((str1 > str2) ? 1 : 0));
    });
  }
  else {
    myArray.sort(function (a, b) {

      var str1 = $(a).data("sort").toString();
      var str2 = $(b).data("sort").toString();
      if(str1 == "")
        return 1;
      if(str2 == "")
        return -1;
      if(str1.length > str2.length & str1.slice(0,str2.length) === str2)
        return -1
      if(str2.length > str1.length & str2.slice(0,str1.length) === str1)
        return 1
      return ((str1 < str2) ? 1 : ((str1 > str2) ? -1 : 0));
    });
  }
  $('ol.catalog').append(myArray)
});