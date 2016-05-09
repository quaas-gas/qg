json.array!(@deliveries) do |delivery|
  json.extract! delivery, :id, :number, :number_show, :customer_id, :date, :driver, :description, :invoice_number, :on_account, :discount_net, :discount
  json.url delivery_url(delivery, format: :json)
end
