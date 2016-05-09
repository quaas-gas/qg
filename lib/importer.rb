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

  def self.import_deliveries(with_delete: false)

    reset(Delivery) if with_delete

    exceptions = %w(amount amount_net cert_price deposit_price disposal_price bg tg btg)

    Delivery.transaction do
      xml_data('deliveries').each do |delivery|
        Delivery.create node_to_hash(delivery).except(*exceptions)
      end
    end
  end

  def self.monetize(val = nil)
    val ||= '0'
    val = val.to_f * 10000
    Money.new val, 'Eu4'
  end

  def self.import_bottles(with_delete: false)

    reset(Bottle) if with_delete

    xml_data('bottles').each do |node|
      hash = node_to_hash(node)
      hash[:number]             = hash.delete 'id'
      hash[:cert_price]         = monetize(hash.delete('cert_price'))
      hash[:cert_price_net]     = monetize(hash.delete('cert_price_net'))
      hash[:deposit_price]      = monetize(hash.delete('deposit_price'))
      hash[:deposit_price_net]  = monetize(hash.delete('deposit_price_net'))
      hash[:disposal_price]     = monetize(hash.delete('disposal_price'))
      hash[:disposal_price_net] = monetize(hash.delete('disposal_price_net'))
      Bottle.create! hash
    end
  end

  def self.import_prices(with_delete: false)

    reset(Price) if with_delete
    exceptions = %w(stock_current_date stock_current stock_invoice stock_invoice_date )

    xml_data('prices').each do |node|
      hash = node_to_hash(node).except(*exceptions)
      hash[:bottle]   = Bottle.find_by(number: hash.delete('bottle_id'))
      hash[:price]    = monetize(hash.delete('price'))
      hash[:discount] = monetize(hash.delete('discount'))
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
