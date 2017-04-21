task delete_unused_products: :environment do
  Product.all.each do |product|
    product.destroy if product.prices.none? && product.delivery_items.none?
  end
end
