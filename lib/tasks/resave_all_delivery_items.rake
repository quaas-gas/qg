task resave_all_delivery_items: :environment do
  puts "Updating #{DeliveryItem.count} delivery items"
  DeliveryItem.includes(:product).find_each do |item|
    item.save
    print '.'
  end
  puts ' ', 'done'
end
