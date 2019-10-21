json.explore_collections do
  json.partial! 'api/v1/collection/collection', collection: @collections['response']['docs'], as: :single_collection
end

json.featured_works do
  json.partial! 'api/v1/work/work', collection: @featured_works['response']['docs'], as: :work
end

json.recent_works do
  json.partial! 'api/v1/work/work', collection: @recent_documents['response']['docs'], as: :work
end
