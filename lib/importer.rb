module Importer

  def self.node_to_hash(node)
    node.children.select(&:element?).each_with_object({}) do |value_node, hsh|
      hsh[value_node.name] = value_node.text
    end
  end

  def self.reset(model)
    model.delete_all
    ActiveRecord::Base.connection.reset_pk_sequence!(model.table_name)
  end

  def self.import_customers(with_delete: false)

    reset(Customer) if with_delete

    doc = Nokogiri::XML(File.open(Rails.root.join('db', 'seeds','customers.xml')))
    doc.xpath('//customers').each { |customer| Customer.create! node_to_hash(customer) }
  end

  def self.import_deliveries(with_delete: false)

    # reset(Delivery) if with_delete

    doc = Nokogiri::XML(File.open(Rails.root.join('db', 'seeds','deliveries.xml')))
    doc.xpath('//deliveries[1]').each do |delivery|
      # Delivery.create node_to_hash(delivery)
    end
  end
end
