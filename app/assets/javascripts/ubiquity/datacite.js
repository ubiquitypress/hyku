$(document).on("turbolinks:load", function(event){
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
        if($('.ubiquity-official-link').length != 0 && result.data.official_url != null) {
          field_array.push('Official URL')
          $('.ubiquity-official-link').val(result.data.official_url)
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
        if($('.ubiquity-volume').length != 0 && result.data.volume != null) {
          field_array.push('Volume')
          $('.ubiquity-volume').val(result.data.volume);
        }
        if($('.ubiquity-issue').length != 0 && result.data.issue != null) {
          field_array.push('Issue')
          $('.ubiquity-issue').val(result.data.issue);
        }
        if($('.ubiquity-pagination').length != 0 && result.data.pagination != null) {
          field_array.push('Pagination')
          $('.ubiquity-pagination').val(result.data.pagination);
        }
        if($('.ubiquity-license').length != 0 && result.data.license != null) {
          field_array.push('Licence')
          $('.ubiquity-license').val(result.data.license);
        }
        if($('.ubiquity-funder').length != 0 && result.data.funder != null) {
          field_array.push('Funder')
          $('.ubiquity-funder').val(result.data.funder);
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
          populateCreatorValues(result.data.creator_group);
        }
        if ($(".ubiquity-meta-contributor").length != 0 && result.data.contributor_group != null) {
          field_array.push('Contributor')
          populateContributorValues(result.data.contributor_group);
        }
        if ($(".ubiquity-keyword").length != 0 && result.data.keyword != null) {
          field_array.push('Keyword')
          populateKeyword(result.data.keyword)
        }
        if ($(".ubiquity-version-number").length != 0 && result.data.version != null) {
          field_array.push('Version')
          $(".ubiquity-version-number").val(result.data.version)
        }
        //IE11 will not show the ,message when .val() is used hence .html()
        var message = "The following fields were auto-populated " + field_array.slice(0, field_array.length - 1).join(', ') + ", and " + field_array.slice(-1);
        $(".ubiquity-fields-populated").html(message)
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
    addOrganizationalValues('creator', key, value);
    addPersonalValues('creator', key, value);
  })
}

function populateContributorValues(contributorArray){
  $.each(contributorArray, function(key, value){
    addOrganizationalValues('contributor', key, value);
    addPersonalValues('contributor', key, value);
  })
}

function addPersonalValues(fieldName, key, value) {
  var familyName = '.' + fieldName + '_family_name:last'
  var givenName = '.' + fieldName + '_given_name:last'
  var givenName2 = '.' + fieldName + '_given_name'
  var orcid = '.' + fieldName + '_orcid:last'
  var position = '.' + fieldName + '_position:last'
  var nameType = '.' + 'ubiquity_' + fieldName + '_name_type:last'

  if (key === 0) {
    var newParent = '.ubiquity-meta-' + fieldName
    var parent = $(newParent);
    var div = parent.children(".ubiquity_personal_fields:last")
    div.children(familyName).val(value[fieldName + '_family_name'])
    div.children(givenName2).val(value[fieldName + '_given_name'])
    div.children(orcid).val(getValidOrcid(value[fieldName + '_orcid']))
    div.children(position).val(value[fieldName + '_position'])
    parent.children(nameType).val('Personal').change()
  }else {
    var newParent = '.ubiquity-meta-' + fieldName + ':last'
    var parent = $(newParent);
    var parentClone = parent.clone();
    var div = parentClone.children(".ubiquity_personal_fields:last")
    parentClone.find('input').val('');
    parentClone.find('option').attr('selected', false);
    parent.after(parentClone)
    parentClone.find(familyName).val(value[fieldName + '_family_name'])
    parentClone.find(givenName).val(value[fieldName + '_given_name'])
    div.children(orcid).val(getValidOrcid(value[fieldName + '_orcid']))
    parentClone.find(position).val(value[fieldName + '_position'])
    parentClone.find(nameType).val('Personal').change()
  }
}

function addOrganizationalValues(fieldName, key, value) {
  var name = '.ubiquity_' + fieldName + '_organization_name:last'
  var name2 = '.ubiquity_' + fieldName + '_organization_name'
  var isni = '.ubiquity_' + fieldName + '_isni:last'
  var position = '.' + fieldName + '_position:last'
  var nameType = '.' + 'ubiquity_' + fieldName + '_name_type:last'

  if (key === 0) {
    var newParent = '.ubiquity-meta-' + fieldName
    var parent = $(newParent);
    var div = parent.children(".ubiquity_organization_fields:last")
    div.children(name2).val(value[fieldName + '_organization_name'])
    div.children(isni).val(value[fieldName + '_isni'])
    div.children(position).val(value[fieldName + '_position'])
    parent.children(nameType).val('Organisational').change()
  }else {
    var newParent = '.ubiquity-meta-' + fieldName + ':last'
    var parent = $(newParent);
    var parentClone = parent.clone();
    var div = parentClone.children(".ubiquity_organization_fields:last")
    parentClone.find('input').val('');
    parentClone.find('option').attr('selected', false);
    parent.after(parentClone)
    parentClone.find(name).val(value[fieldName + '_organization_name'])
    parentClone.find(isni).val(value[fieldName + '_isni'])
    parentClone.find(position).val(value[fieldName + '_position'])
    parentClone.find(nameType).val('Organisational').change()
  }
}

function getValidOrcid(orcidPath) {
  if (orcidPath != null) {
    var orcidArray = orcidPath.split("/")
    var validOrcid  = orcidArray.slice(-1)[0]
  }
  return validOrcid
}
