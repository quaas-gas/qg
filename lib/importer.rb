module Importer
  def self.import_customers
    doc = Nokogiri::XML(File.open(Rails.root.join('db', 'seeds','customers.xml')))
    doc.xpath('//customers').each do |customer_node|
      customer_hash = customer_node.children.each_with_object({}) do |child_node, hsh|
        next unless child_node.element?
        hsh[child_node.name] = child_node.text
      end
      customer_hash[:gets_invoice] = customer_hash.delete 'invoice'
      customer_hash[:price_in_net] = customer_hash.delete 'net'
      customer_hash[:has_stock]    = customer_hash.delete 'stock'
      customer_hash.delete 'KDN'

      Customer.create! customer_hash
    end

    # ActiveRecord::Base.connection.reset_pk_sequence!(Customer.table_name)
  end
end
