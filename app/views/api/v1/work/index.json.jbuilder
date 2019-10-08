
json.total @total_count

json.items do
  json.partial! 'api/v1/work/work_only', collection: @works, as: :work, cached: true
end
