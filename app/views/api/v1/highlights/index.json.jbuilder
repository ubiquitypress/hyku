json.explore_collections do
  json.partial! 'api/v1/collection/collection', collection: @collections, as: :single_collection
end

json.featured_works do
  json.partial! 'api/v1/work/work_only', collection: @featured_works, as: :work
end

json.recent_works do
  json.partial! 'api/v1/work/work_only', collection: @recent_documents, as: :work
end
