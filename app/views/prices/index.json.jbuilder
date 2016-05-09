json.array!(@prices) do |price|
  json.extract! price, :id, :customer_id, :bottle_id, :valid_from, :price, :discount
  json.url price_url(price, format: :json)
end
