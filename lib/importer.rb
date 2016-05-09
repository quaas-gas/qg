module Importer

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

    doc = Nokogiri::XML(File.open(Rails.root.join('db', 'seeds','customers.xml')))
    doc.xpath('//customers').each { |customer| Customer.create! node_to_hash(customer) }
  end

  def self.import_deliveries(with_delete: false)

    reset(Delivery) if with_delete

    exceptions = %w(amount amount_net cert_price deposit_price disposal_price bg tg btg)

    doc = Nokogiri::XML(File.open(Rails.root.join('db', 'seeds','deliveries.xml')))
    Delivery.transaction do
      doc.xpath('//deliveries').each do |delivery|
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

    doc = Nokogiri::XML(File.open(Rails.root.join('db', 'seeds','bottles.xml')))
    doc.xpath('//bottles').each do |delivery|
      hash = node_to_hash(delivery)
      hash[:number]             = hash.delete 'id'
      hash[:cert_price]         = monetize(hash.delete('cert_price'))
      hash[:cert_price_net]     = monetize(hash.delete('cert_price_net'))
      hash[:deposit_price]      = monetize(hash.delete('deposit_price'))
      hash[:deposit_price_net]  = monetize(hash.delete('deposit_price_net'))
      hash[:disposal_price]     = monetize(hash.delete('disposal_price'))
      hash[:disposal_price_net] = monetize(hash.delete('disposal_price_net'))
      puts hash
      Bottle.create! hash
    end
  end

end
