
json.total @works.presence && @works['response']['numFound']
work_records =  @works.presence && @works['response']['docs']

json.items do
  if work_records.present?
    json.array! @works['response']['docs']  do |work|
      @work = work
      json.partial! 'api/v1/work/work', work: @work
    end
  end
end
