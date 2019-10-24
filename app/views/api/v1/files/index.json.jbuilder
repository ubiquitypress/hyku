
json.array! @files['response']['docs'] do |work|
  json.uuid   work[:id]
  json.type    'file_set'
  json.name    work['title_tesim'].first
  json.mimetype   work['mime_type_ssi']

  get_file_licence =  Ubiquity::ApiUtils.query_for_file_licence(work[:id])
  if get_file_licence.present?
    json.file_licence  get_file_licence
  else
    json.file_licence nil
  end

  json.thumbnail_url   ('https://' + work['account_cname_tesim'].first + work['thumbnail_path_ss'])
  json.date_uploaded  work['date_uploaded_dtsi']
  json.visibility  work['visibility_ssi']
  json.size   work['file_size_lts']
  json.download_link 'https://' + work['account_cname_tesim'].first + main_app.fail_uploads_download_file_path(fileset_id: work[:id])
end
