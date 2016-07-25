json.array!(@statistics) do |statistic|
  json.extract! statistic, :id, :name, :time_range, :grouping, :filter, :sums_of
  json.url statistic_url(statistic, format: :json)
end
