
json.array! @files['response']['docs'] do |work|
  json.uuid   work[:id]
  json.type    'file_set'
  json.name    work['title_tesim'].first
  json.mimetype   work['mime_type_ssi']

  license_array = work['license_tesim']
  license_hash = Hyrax::LicenseService.new.select_all_options.to_h
  if license_array.present?
    json.license do
      json.array! license_array do |item|
        if license_hash.values.include?(item)
          json.name  license_hash.key(item)
          json.link  item
        end
      end
    end
  else
    json.license   nil
  end

  json.thumbnail_url   ('https://' + work['account_cname_tesim'].first + work['thumbnail_path_ss'])
  json.date_uploaded  work['date_uploaded_dtsi']
  json.current_visibility  work['visibility_ssi']
  json.embargo_release_date  work['embargo_release_date_dtsi']
  json.lease_expiration_date  work['lease_expiration_date_dtsi']
  json.size   work['file_size_lts']
  json.download_link 'https://' + work['account_cname_tesim'].first + main_app.fail_uploads_download_file_path(fileset_id: work[:id])
end
