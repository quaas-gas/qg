json.array!(@products) do |product|
  json.extract! product, :id, :number, :name, :content, :price, :price_net
  json.url product_url(product, format: :json)
end
