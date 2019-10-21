json.total @collections['response']['numFound']

json.items do
  json.partial! 'api/v1/collection/collection', collection: @collections['response']['docs'], as: :single_collection
end
