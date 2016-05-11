module Importer

  def self.xml_data(file_name, node_name = nil)
    node_name ||= file_name
    file_name = Rails.root.join('db', 'seeds', "#{file_name}.xml")
    Nokogiri::XML(File.open(file_name)).xpath("//#{node_name}")
  end

  def self.node_to_hash(node)
    node.children.select(&:element?).each_with_object({}) do |value_node, hsh|
      hsh[value_node.name] = value_node.text
    end
  end

  def self.reset(model)
    puts model.delete_all
    puts ActiveRecord::Base.connection.reset_pk_sequence!(model.table_name)
  end

  def self.import_customers(with_delete: false)
    reset(Customer) if with_delete
    xml_data('customers').each { |customer| Customer.create! node_to_hash(customer) }
    Customer.where(price_in_net: true).update_all(tax: false)
    Customer.where(price_in_net: false).update_all(tax: true)
    Customer.count
  end

  def self.monetize(val: nil, currency: 'EU4NET')
    val ||= 0
    Money.from_amount val.to_f, currency
  end

  def self.import_deliveries(with_delete: false)
    reset(Delivery) if with_delete
    exceptions = %w(amount amount_net cert_price deposit_price disposal_price bg tg btg discount_net discount)
    ActiveRecord::Base.logger.level = 1

    batch_size = 1000
    count = 0
    PgSearch.disable_multisearch do
      Delivery.transaction do
        xml_data('deliveries').each_slice(batch_size) do |batch|
          deliveries = []
          batch.each do |delivery|
            data = node_to_hash(delivery)
            hash = data.except(*exceptions)
            hash[:others] = data.to_json
            deliveries << hash
          end
          Delivery.create! deliveries
          puts (count += batch_size)
        end
      end
    end
    Delivery.where(customer: Customer.tax).update_all(tax: true)
    Delivery.where(customer: Customer.nontax).update_all(tax: false)
    Delivery.count
  end

  def self.import_products(with_delete: false)
    reset(Product) if with_delete
    exceptions = %w(cert_price cert_price_net deposit_price deposit_price_net disposal_price disposal_price_net)

    products = xml_data('bottles').map do |node|
      data = node_to_hash(node)
      hash = data.except(*exceptions)
      hash[:others] = data.to_json
      hash[:number] = hash.delete 'id'
      hash[:category] = hash.delete 'gas'
      hash
    end
    Product.create! products
    Product.count
  end

  def self.import_prices(with_delete: false)
    reset(Price) if with_delete
    exceptions = %w(stock_current_date stock_current stock_invoice stock_invoice_date )

    prices = xml_data('prices').map do |node|
      data = node_to_hash(node)
      hash = data.except(*exceptions)
      hash[:others] = data.to_json
      hash[:product] = Product.find_by(number: hash.delete('bottle_id'))
      customer = Customer.find_by id: hash['customer_id']
      currency = customer.price_in_net ? 'EU4NET' : 'EU4TAX'
      hash[:price]     = monetize(val: hash.delete('price'), currency: currency)
      hash[:discount]  = monetize(val: hash.delete('discount'), currency: currency)
      hash
    end
    Price.create! prices
    Price.count
  end

  def self.import_sellers(with_delete: false)
    reset(Seller) if with_delete

    sellers = xml_data('driver').map do |node|
      hash = node_to_hash(node)
      hash[:short] = hash.delete 'id'
      hash
    end
    Seller.create! sellers
    Seller.count
  end

  def self.link_deliveries_with_sellers
    Seller.all.each do |seller|
      Delivery.where(driver: seller.short).update_all(seller_id: seller.id)
    end
  end

  def self.import_delivery_items(with_delete: false)
    if with_delete
      ActiveRecord::Base.connection.execute('DELETE FROM delivery_items_imports')
      ActiveRecord::Base.connection.reset_pk_sequence!('delivery_items_imports')
    end

    attrs = %w(id delivery_id bottle_id count_full count_empty stock_new total_kg price price_net price_total price_total_net)
    xml_data('deliveries_gas').each_slice(100) do |batch|
      inserts = batch.map do |node|
        hash = node_to_hash(node)
        values = attrs.map { |attr| hash[attr].nil? ? 'NULL' : "'#{hash[attr]}'" }
        "(#{values.join(', ')})"
      end
      sql = "INSERT INTO delivery_items_imports (#{attrs.join(', ')}) VALUES #{inserts.join(', ')}"
      ActiveRecord::Base.connection.execute(sql)
    end
  end

  def self.import_delivery_items2(with_delete: false)
    reset(DeliveryItem) if with_delete
    puts 'insert 156.355 items ...'
    products = {}
    Product.all.each { |p| products[p.number] = p }

    batch_size = 1000
    count = 0
    sql = 'SELECT delivery_id, bottle_id, count_full as count, count_empty as count_back, price, price_net FROM delivery_items_imports'
    DeliveryItem.transaction do
      ActiveRecord::Base.connection.execute(sql).each_slice(batch_size) do |batch|
        items = batch.map do |hash|
          delivery           = Delivery.find_by number: hash.delete('delivery_id')
          product            = products[hash.delete('bottle_id')]
          net                = monetize(val: hash.delete('price_net'), currency: 'EU4NET')
          tax                = monetize(val: hash.delete('price'), currency: 'EU4TAX')
          hash[:delivery_id] = delivery.id
          hash[:product_id]  = product.id
          hash[:unit_price]  = delivery.tax ? tax : net
          hash
        end
        DeliveryItem.create! items
        puts (count += batch_size)
      end
    end
    DeliveryItem.count
  end

  def self.import_other_products

    xml_data('products').map do |node|
      hash = node_to_hash(node)
      product = Product.find_by number: hash['number']
      if product
        product.update category: hash['category']
      else
        Product.create! hash
      end
    end
    Setting.product_categories = Product.pluck(:category).uniq.compact.sort
  end

  def self.product_number(category, bottle_id)
    return 'schrott-bg' if category == 'Schrott'
    category = ({ 'TÜV' => 'tüv', 'Pfand' => 'pfand' }[category])
    [category, bottle_id].join('-')
    # "#{category}-#{bottle_id}"
  end

  def self.import_other_delivery_items
    products = {}
    Product.all.each { |p| products[p.number] = p }

    batch_size = 1000
    count = 0
    DeliveryItem.transaction do
      xml_data('deliveries_other', 'deliveries_other').each_slice(batch_size) do |batch|
        items = batch.map do |node|
          hash      = node_to_hash(node)
          delivery  = Delivery.find_by number: hash.delete('delivery_id')
          bottle_id = hash.delete 'bottle_id'
          category  = hash.delete 'product'
          p_number  = product_number(category, bottle_id)
          unless products[p_number]
            if p_number
              products[p_number] = Product.create!(
                number: p_number, category: 'Gebühr', name: "Gebühr für #{p_number}"
              )
            else
              puts category, bottle_id
            end
          end
          product        = products[p_number]
          hash[:product_id] = product.id
          net                = monetize(val: hash.delete('price_net'), currency: 'EU4NET')
          tax                = monetize(val: hash.delete('price'), currency: 'EU4TAX')
          hash[:delivery_id] = delivery.id
          hash[:unit_price]  = delivery.tax ? tax : net
          hash.delete 'id'
          hash.delete 'price_total'
          hash.delete 'price_total_net'
          hash
        end
        DeliveryItem.create! items
        puts (count += batch_size)
      end
    end

  end

end
