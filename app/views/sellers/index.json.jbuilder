json.array!(@sellers) do |seller|
  json.extract! seller, :id, :short, :first_name, :last_name, :mobile
  json.url seller_url(seller, format: :json)
end
