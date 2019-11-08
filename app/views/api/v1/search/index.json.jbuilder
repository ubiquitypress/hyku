json.total @works['response']['numFound']

json.items do
  json.array! @works['response']['docs']  do |work|
    if work['has_model_ssim'] == 'Collection'
      json.partial! 'api/v1/collection/collection', work: work
    else
      json.partial! 'api/v1/work/work', work: work
    end
  end
end

json.facet_counts do
   @works['facet_counts']['facet_fields'].each  do |key, value|
    #converts {resource_type_sim:  ["Dataset default Dataset", 4, "Book default Book", 2, "GenericWork Patent", 1, "TimeBasedMedia Audio", 1]}
    # into this form
    # {Just  using resource_type facet as an example of how each should return data}
    data = {key  => Hash[*value] }
    json.merge! data
  end
end
