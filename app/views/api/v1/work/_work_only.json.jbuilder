  json.uuid    work.id
  json.related_url    work.try(:related_url)
  json.type 'work'
  json.work_type    work.try(:has_model).try(:first)
  json.title    work.title.try(:first)
  json.alternative_title    work.try(:alternative_title)
  json.resource_type    work.resource_type.first.try(:split).try(:first)
  creator = work.creator.try(:first)
  if valid_json?(creator)
    json.creator JSON.parse(creator)
  end

  contributor = work.contributor.try(:first)
  if valid_json?(contributor)
   json.contributor JSON.parse(contributor)
  end

  editor = work.try(:editor).try(:first)
  if valid_json?(editor)
    json.editor JSON.parse(editor)
  end

  json.abstract    work.try(:abstract)
  json.date_published    work.date_published
  json.institution    work.institution
  json.organisational_unit    work.org_unit
  json.project_name    work.project_name
  json.funder    work.funder
  json.publisher   work.publisher
  json.date_accepted    work.date_accepted
  json.date_submitted    work.date_submitted
  json.official_url    work.try(:official_url)
  json.language    work.language
  json.license  work.license_for_api
  json.rights_statement  work.rights_statements_for_api
  json.rights_holder    work.rights_holder
  json.doi    work.doi

  json.alternate_identifier  work.alternate_identifier_for_api

  json.peer_reviewed    work.try(:peer_reviewed)
  json.keywords    work.keyword
  json.dewey    work.dewey
  json.library_of_congress_classification    work.library_of_congress_classification
  json.additional_info    work.try(:add_info)

  json.related_identifier work.related_identifier_for_api

  json.version    work.try(:version)
  json.duration    work.try(:duration)
  json.pagination    work.pagination
  json.series_name    work.try(:series_name)
  json.issue    work.try(:issue)
  json.volume    work.try(:volume)
  json.material_media    work.try(:material_media)
  json.edition    work.try(:edition)

  event = work.try(:event).try(:first)
  if valid_json?(event)
    json.event JSON.parse(event)
  end
  json.journal_title    work.try(:journal_title)
  json.book_title    work.try(:book_title)
  json.article_number    work.try(:article_number)
  json.eissn    work.try(:eissn)
  json.issn    work.try(:issn)
  json.isbn    work.try(:isbn)
  json.current_he_institution    work.try(:current_he_institution)
  json.qualification    work.try(:qualification)
  json.alternative_journal_title    work.try(:alternative_journal_title)

  if work.thumbnail.present?
    img_path = CGI.escape(ActiveFedora::File.uri_to_id(work.thumbnail.original_file.versions.all.last.uri))
    image_link = image_url("#{img_path}/full/150,120/0/default.jpg")
    json.thumbnail_url   image_link
  else
    json.thumbnail_url  ''
  end

  json.files work.work_filesets_summary_for_api
  json.collections work.member_of_collections_for_api
