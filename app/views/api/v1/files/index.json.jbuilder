
json.array! @files['response']['docs'] do |work|
  json.name    work['title_tesim'].first
  json.mimetype   work['mime_type_ssi']
  json.license   work['license_for_api_tesim']
  json.thumbnail_url   ('https://' + work['account_cname_tesim'].first + work['thumbnail_path_ss'])
  json.date_uploaded  work['date_uploaded_dtsi']
  json.visibility  work['visibility_ssi']
  json.size   work['file_size_lts']
  json.download_link ('https://' + work['account_cname_tesim'].first + '/' + 'downloads' + '/' + work[:id])
end
