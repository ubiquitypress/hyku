json.explore_collections do
  json.partial! 'api/v1/collection/collection', collection: @collections, as: :single_collection, cached: true
end

json.featured_works do
  json.partial! 'api/v1/work/work_only', collection: @featured_works, as: :work, cached: true
end

json.recent_works do
  json.partial! 'api/v1/work/work_only', collection: @recent_documents, as: :work, cached: true
end
