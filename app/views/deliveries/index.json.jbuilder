json.array!(@deliveries) do |delivery|
  json.extract! delivery, :id, :number, :number_show, :customer_id, :date, :seller_id, :description,
                :invoice_number, :tax, :on_account
  json.customer delivery.customer.name
  json.seller delivery.seller&.short
  json.url delivery_url(delivery, format: :json)
end
