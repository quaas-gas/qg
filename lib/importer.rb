module Importer
  def self.import_customers(with_delete: false)

    if with_delete
      Customer.delete_all
      ActiveRecord::Base.connection.reset_pk_sequence!(Customer.table_name)
    end

    doc = Nokogiri::XML(File.open(Rails.root.join('db', 'seeds','customers.xml')))
    doc.xpath('//customers').each do |customer_node|
      data_nodes = customer_node.children.select(&:element?)
      customer_hash = data_nodes.each_with_object({}) do |child_node, hsh|
        hsh[child_node.name] = child_node.text
      end
      Customer.create! customer_hash
    end
  end
end
