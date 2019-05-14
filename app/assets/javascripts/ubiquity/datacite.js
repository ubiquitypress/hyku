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
  $.ajax({
    url: fullHost,
    type: "POST",
    data: {"url": url},
    success: function(result){
      if (result.data.error  === undefined) {
        $(".ubiquity-title").val(result.data.title)
        $('.ubiquity-abstract').val(result.data.abstract)
        $('.ubiquity-doi').val(result.data.doi)
        //populate dropdown
        $('.ubiquity-date-published-year').val(result.data.published_year);
        $('.ubiquity-date-published-month').val(result.data.published_month);
        $('.ubiquity-date-published-day').val(result.data.published_day);
        $('.ubiquity-license').val(result.data.license);
        $('.ubiquity-issn').val(result.data.issn);
        $('.ubiquity-journal-title').val(result.data.journal_title);
        $('.ubiquity-eissn').val(result.data.eissn);
        $('.ubiquity-isbn').val(result.data.isbn);
        $('.ubiquity-publisher').val(result.data.publisher);
        populateRelatedIdentifierValues(result.data.related_identifier_group)
        populateCreatorValues(result.data.creator_group)
        populateKeyword(result.data.keyword)
        //IE11 will not show the ,message when .val() is used hence .html()
        $(".ubiquity-fields-populated").html(result.data.auto_populated)
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
