$(document).on("turbolinks:load", function(event) {
  return $("body").on("submit", ".get-datacite-doi-metadata-select", function(event){
    var dataciteUrl = $(".ubiquity-datacite-value").val();
    $(".ubiquity-fields-populated").hide()
    $(".ubiquity-fields-populated-error").hide()

    event.preventDefault();
    fetchDataciteData(dataciteUrl);
    $("#get-datacite-doi-metadata").modal('hide')
  });
});

function fetchDataciteData(url) {
  var host = window.document.location.host;
  var protocol = window.document.location.protocol;
  var fullHost = protocol + '//' + host + '/available_ubiquity_titles/call_datasite';
  var field_array = [];
  $.ajax({
    url: fullHost,
    type: "POST",
    data: {"url": url},
    success: function(result){
      if (result.data.error  === undefined) {
        if($('.ubiquity-title').length != 0 && result.data.title != null) {
          $(".ubiquity-title").val(result.data.title)
          field_array.push('Title')
        }
        if ($('.ubiquity-abstract').length != 0 && result.data.abstract != null) {
          field_array.push('Abstract')
          $('.ubiquity-abstract').val(result.data.abstract)
        }
        if($('.ubiquity-doi').length != 0 && result.data.doi != null) {
          field_array.push('DOI')
          $('.ubiquity-doi').val(result.data.doi)
        }
        //populate dropdown
        if($('.ubiquity-date-published-year').length != 0 && result.data.published_year != null) {
          field_array.push('Published Year')
          $('.ubiquity-date-published-year').val(result.data.published_year);
        }
        if($('.ubiquity-date-published-month').length != 0 && result.data.published_month != null) {
          field_array.push('Published Month')
          $('.ubiquity-date-published-month').val(result.data.published_month);
        }
        if($('.ubiquity-date-published-day').length != 0 && result.data.published_day != null) {
          field_array.push('Published Day')
          $('.ubiquity-date-published-day').val(result.data.published_day);
        }
        if($('.ubiquity-license').length != 0 && result.data.license != null) {
          field_array.push('Licence')
          $('.ubiquity-license').val(result.data.license);
        }
        if($('.ubiquity-issn').length != 0 && result.data.issn != null) {
          field_array.push('ISSN')
          $('.ubiquity-issn').val(result.data.issn);
        }
        if($('.ubiquity-journal-title').length != 0 && result.data.journal_title != null) {
          field_array.push('Journal Title')
          $('.ubiquity-journal-title').val(result.data.journal_title);
        }
        if($('.ubiquity-eissn').length != 0 && result.data.eissn != null) {
          field_array.push('eISSN')
          $('.ubiquity-eissn').val(result.data.eissn);
        }
        if($('.ubiquity-isbn').length != 0 && result.data.isbn != null) {
          field_array.push('ISBN')
          $('.ubiquity-isbn').val(result.data.isbn);
        }
        if($('.ubiquity-publisher').length != 0 && result.data.publisher != null) {
          field_array.push('Publisher')
          $('.ubiquity-publisher').val(result.data.publisher);
        }
        if ($(".ubiquity-meta-related-identifier") != 0 && result.data.related_identifier_group != null) {
          field_array.push('Related Identifier')
          populateRelatedIdentifierValues(result.data.related_identifier_group)
        }
        if ($(".ubiquity-meta-creator").length != 0 && result.data.creator_group != null) {
          field_array.push('Creator')
          populateCreatorValues(result.data.creator_group)
        }
        if ($(".ubiquity-keyword").length != 0 && result.data.keyword != null) {
          field_array.push('Keyword')
          populateKeyword(result.data.keyword)
        }
        //IE11 will not show the ,message when .val() is used hence .html()
        var str = "The following fields were auto-populated " + field_array.slice(0, field_array.length - 1).join(', ') + ", and " + field_array.slice(-1);
        $(".ubiquity-fields-populated").html(str)
        $(".ubiquity-fields-populated").show()
      } else {
        $(".ubiquity-fields-populated-error").html(result.data.error)
        $(".ubiquity-fields-populated-error").show()
      }
    }
  }) //closes $.ajax
}

function populateRelatedIdentifierValues(relatedArray){
  $.each(relatedArray, function(key, value){
      addValues(key, value);
  })
}

function populateKeyword(keywordArray){
  $.each(keywordArray, function(key, value){
    addKeywordValues(key, value);
  })
}

function addKeywordValues(key, value){
  if (key == 0) {
  $(".ubiquity-keyword:last").val(value)
  }
  else{
    var parent_li = $(".ubiquity-keyword:last").parent();
    var clonedParent = parent_li.clone();
    var parent_ul = parent_li.parent();
    parent_ul.append(clonedParent);
    $(".ubiquity-keyword:last").val(value);
  }
}

function addValues(key, value) {

  if (key === 0) {
    var div = $(".ubiquity-meta-related-identifier");
    div.children(".related_identifier").val(value.related_identifier)
    $('.related_identifier_type').val(value.related_identifier_type).change()
    div.children(".related_identifier_relation:last").val(value.relation_type).change()
  }else {
    var div = $(".ubiquity-meta-related-identifier:last")
    var cloned =  div.clone();
    cloned.find('input').val('');
    cloned.find('option').attr('selected', false);
    div.after(cloned)
    cloned.children(".related_identifier:last").val(value.related_identifier)
    $('.related_identifier_type').val(value.related_identifier_type).change()
    cloned.children(".related_identifier_relation:last").val(value.relation_type).change()
  }
}

function populateCreatorValues(creatorArray){
  $.each(creatorArray, function(key, value){
      addCreatorValues(key, value);
  })
}

function addCreatorValues(key, value) {
  if (key === 0) {
    var parent = $(".ubiquity-meta-creator");
    var div = parent.children(".ubiquity_personal_fields:last")
    div.children(".creator_family_name:last").val(value.creator_family_name)
    div.children('.creator_given_name').val(value.creator_given_name)
    div.children('.creator_orcid:last').val(value.creator_orcid)
    div.children(".creator_position:last").val(value.creator_position)
    parent.children('.ubiquity_creator_name_type:last').val('Personal').change()
  }else {
    var parent = $(".ubiquity-meta-creator:last")
    var parentClone = parent.clone();
    var div = parentClone.children(".ubiquity_personal_fields:last")
    parentClone.find('input').val('');
    parentClone.find('option').attr('selected', false);
    parent.after(parentClone)
    parentClone.find(".creator_family_name:last").val(value.creator_family_name)
    parentClone.find('.creator_given_name:last').val(value.creator_given_name)
    parentClone.find('.creator_orcid:last').val(value.creator_orcid)
    parentClone.find(".creator_position:last").val(value.creator_position)
    parentClone.find('.ubiquity_creator_name_type:last').val('Personal').change()
  }
}
