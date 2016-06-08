json.array!(@customers) do |customer|
  json.extract! customer, :id, :salut, :name, :name2, :street, :city, :zip, :phone, :email, :gets_invoice, :region, :kind, :price_in_net, :has_stock, :invoice_address, :notes
  json.url customer_url(customer, format: :json)
end
