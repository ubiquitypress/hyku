
json.total @works['response']['numFound']

json.items do
  json.array! @works['response']['docs']  do |work|
    json.partial! 'api/v1/work/work', work: work
  end
end
