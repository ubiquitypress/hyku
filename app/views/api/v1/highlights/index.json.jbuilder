
collection_list = @collections.presence && @collections['response']['docs']
if collection_list.present?
  json.explore_collections do
    json.partial! 'api/v1/collection/collection', collection: @collections['response']['docs'], as: :single_collection
  end
else
  json.explore_collections  nil
end

featured = @featured_works.presence && featured_works['response']['docs']

if featured.present?
  json.featured_works do
    json.partial! 'api/v1/work/work', collection: @featured_works['response']['docs'], as: :work
  end
else
  json.featured_works  nil
end

recent = @recent_documents.presence && @recent_documents['response']['docs']
if recent.present?
  json.recent_works do
    json.partial! 'api/v1/work/work', collection: @recent_documents['response']['docs'], as: :work
  end
else
  json.recent_works nil
end

json.featured_order do
  json.array! @featured 
end
