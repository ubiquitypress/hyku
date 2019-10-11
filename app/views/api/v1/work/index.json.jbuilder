
json.total @total_count

json.items do
  @works.map do |work|
    Rails.cache.fetch(@fetch_all_work_jbuilder_cache_name, expires_in: 3.minutes) do
      json.partial! 'api/v1/work/work_only', work: work
    end
  end
end
