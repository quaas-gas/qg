json.array!(@reports) do |report|
  json.extract! report, :id, :name, :product_categories, :products, :in_menu
  json.url report_url(report, format: :json)
end
