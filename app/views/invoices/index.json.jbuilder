json.array!(@invoices) do |invoice|
  json.extract! invoice, :id, :customer_id, :number, :date, :tax, :pre_message, :post_message, :address, :printed
  json.url invoice_url(invoice, format: :json)
end
