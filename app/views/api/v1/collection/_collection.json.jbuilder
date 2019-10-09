
json.uuid    single_collection.id
json.type   'collection'
json.related_url    single_collection.try(:related_url)
json.title    single_collection.title.try(:first)
json.resource_type    single_collection.resource_type.try(:first)
json.date_created    single_collection.date_created

creator = single_collection.creator.try(:first)
if valid_json?(creator)
  json.creator JSON.parse(creator)
end

contributor = single_collection.contributor.try(:first)
if valid_json?(contributor)
 json.contributor JSON.parse(contributor)
end

json.description    single_collection.description.try(:first)
json.keywords    single_collection.keyword
json.license_for_api_tesim    single_collection.license_for_api
json.rights_statements_for_api_tesim    single_collection.rights_statements_for_api
json.language    single_collection.language
json.publisher   single_collection.publisher

json.visbility    single_collection.visibility


if single_collection.thumbnail.present?
  img_path = CGI.escape(ActiveFedora::File.uri_to_id(single_collection.thumbnail.original_file.versions.all.last.uri))
  image_link = image_url("#{img_path}/full/150,120/0/default.jpg")
  json.thumbnail_url   image_link
else
  json.thumbnail_url  ''
end

json.works do
  json.partial! 'api/v1/work/work_only', collection: single_collection.member_objects, as: :work
end
