
json.uuid    single_collection['id']
json.type   'collection'
json.related_url    single_collection['related_url_tesim']
json.title    single_collection['title_tesim'].try(:first)
json.resource_type    single_collection['resource_type_sim'].try(:first)
json.date_created    single_collection['date_created_tesim']

creator = single_collection['creator_tesim'].try(:first)
if valid_json?(creator)
  json.creator JSON.parse(creator)
end

contributor = single_collection['contributor_tesim'].try(:first)
if valid_json?(contributor)
  json.contributor JSON.parse(contributor)
end

editor = single_collection['editor_tesim'].try(:first)
if valid_json?(editor)
  json.editor JSON.parse(editor)
end

json.description    single_collection['description_tesim'].try(:first)
json.date_published    single_collection['date_published_tesim']
json.keywords    single_collection['keyword_tesim']
json.license_for_api_tesim    single_collection['license_for_api_tesim']
json.rights_statements_for_api_tesim    single_collection['rights_statements_for_api_tesim']
json.language    single_collection['language_tesim']
json.publisher   single_collection['publisher_tesim']
json.thumbnail_url    ('https://' + single_collection['account_cname_tesim'].first + single_collection['thumbnail_path_ss'])
json.visibility    single_collection['visibility_ssi']

works = Ubiquity::ApiUtils.query_for_colection_works(single_collection['id'])

json.works do
  json.partial! 'api/v1/work/work', collection: works, as: :work
end
