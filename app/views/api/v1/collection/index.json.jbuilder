
json.total @total_count

json.items do
  @collections.map do |collection|
    Rails.cache.fetch('all_collections' expires_in: 3.minutes) do
      json.partial! 'collection', single_collection: collection
    end
  end
end
