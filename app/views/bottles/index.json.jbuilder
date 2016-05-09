json.array!(@bottles) do |bottle|
  json.extract! bottle, :id, :number, :gas, :size, :name, :content, :cert_price, :cert_price_net, :deposit_price, :deposit_price_net, :disposal_price, :disposal_price_net
  json.url bottle_url(bottle, format: :json)
end
