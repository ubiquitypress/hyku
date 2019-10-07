
json.array! @total_count do |count|
  json.total_count_for_pagination count
end

json.partial! 'collection', collection: @collections, as: :single_collection
