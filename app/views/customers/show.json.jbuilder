json.extract! @customer, :id, :salut, :name, :name2, :own_customer, :street, :city, :zip, :phone, :email, :gets_invoice, :region, :category, :tax, :has_stock, :invoice_address, :created_at, :updated_at
json.link url_for @customer
json.prices @customer.prices.includes(:product) do |price|
  json.product price.product.number
  json.price price.price.to_s
end
