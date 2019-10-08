
json.total @total_count

json.items do
  json.partial! 'collection', collection: @collections, as: :single_collection, cached: true
end
