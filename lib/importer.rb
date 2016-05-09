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
  end

  def self.monetize(val: nil, currency: 'EU4NET')
    val ||= 0
    Money.from_amount val.to_f, currency
  end

  def self.import_deliveries(with_delete: false)

    reset(Delivery) if with_delete

    exceptions = %w(amount amount_net cert_price deposit_price disposal_price bg tg btg discount_net discount)

    PgSearch.disable_multisearch do
      Delivery.transaction do
        xml_data('deliveries').each do |delivery|
          data = node_to_hash(delivery)
          hash = data.except(*exceptions)
          hash[:others] = data.to_json
          Delivery.create! hash
        end
      end
    end
  end

  def self.import_products(with_delete: false)

    reset(Product) if with_delete
    exceptions = %w(gas cert_price cert_price_net deposit_price deposit_price_net disposal_price disposal_price_net)

    xml_data('bottles').each do |node|
      data = node_to_hash(node)
      hash = data.except(*exceptions)
      hash[:others] = data.to_json
      hash[:number] = hash.delete 'id'
      Product.create! hash
    end
  end

  def self.import_prices(with_delete: false)

    reset(Price) if with_delete
    exceptions = %w(stock_current_date stock_current stock_invoice stock_invoice_date )

    xml_data('prices').each do |node|
      data = node_to_hash(node)
      hash = data.except(*exceptions)
      hash[:others] = data.to_json
      hash[:product] = Product.find_by(number: hash.delete('bottle_id'))
      customer = Customer.find_by id: hash['customer_id']
      currency = customer.price_in_net ? 'EU4NET' : 'EU4TAX'
      hash[:price]     = monetize(val: hash.delete('price'), currency: currency)
      hash[:discount]  = monetize(val: hash.delete('discount'), currency: currency)
      Price.create! hash
    end
  end

  def self.import_sellers(with_delete: false)

    reset(Seller) if with_delete

    xml_data('driver').each do |node|
      hash = node_to_hash(node)
      hash[:short] = hash.delete 'id'
      Seller.create! hash
    end
  end

  def self.link_deliveries_with_sellers
    Seller.all.each do |seller|
      Delivery.where(driver: seller.short).update_all(seller_id: seller.id)
    end
  end

end
