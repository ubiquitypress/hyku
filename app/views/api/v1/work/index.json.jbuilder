
json.array! @total_count do |count|
  json.total_count_for_pagination count
end

json.partial! 'api/v1/work/work_only', collection: @works, as: :work
