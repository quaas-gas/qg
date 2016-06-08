module Importer

  class XmlNode
    def initialize(node, tax = nil)
      @node = node
      @tax = tax.nil? ? (attr('tax') == '1') : tax
    end

    def attr(name)
      @node.attributes[name]&.text
    end

    def text_element(name)
      @node.elements.find { |el| el.name == name }&.text
    end

    def elements(name)
      @node.elements.select { |el| el.name == name }
    end

    def monetize(field)
      val = attr(field) || 0
      Money.from_amount val.to_f, (@tax ? 'EU4TAX' : 'EU4NET')
    end
  end

  class CustomerNode < XmlNode
    def to_h
      @node.to_h.merge 'invoice_address' => text_element('invoice_address')
    end

    def prices
      elements('Price').map { |price| PriceNode.new(price, @tax).to_h }
    end

    def deliveries
      elements('Delivery').map { |delivery| DeliveryNode.new(delivery, @tax).to_h }
    end

    def invoices
      elements('Invoice').map { |invoice| InvoiceNode.new(invoice, @tax).to_h }
    end
  end

  class PriceNode < XmlNode
    def to_h
      {
        product_id: Setting.product_map[attr('product_number')],
        price:    monetize('price'),
        discount: monetize('discount'),
        active:   true,
        in_stock: true
      }
    end
  end

  class DeliveryNode < XmlNode
    def to_h
      {
        number:           attr('number'),
        number_show:      attr('number_show'),
        tax:              @tax,
        seller_id:        Setting.seller_map[attr('seller')],
        date:             Date.strptime(attr('date'), '%m/%d/%Y'),
        items_attributes: elements('Item').map { |item| DeliveryItemNode.new(item, @tax).to_h }
      }
    end
  end

  class DeliveryItemNode < XmlNode
    def to_h
      {
        product_id: Setting.product_map[attr('product_number')],
        count:      attr('count'),
        count_back: attr('count_back'),
        unit_price: monetize(@tax ? 'unit_price_tax' : 'unit_price_net')
      }
    end
  end

  class InvoiceNode < XmlNode
    def to_h
      {
        number:           attr('number'),
        date:             Date.strptime(attr('date'), '%m/%d/%Y'),
        tax:              @tax,
        printed:          (attr('printed').to_i > 0),
        address:          text_element('address'),
        pre_message:      text_element('pre_message'),
        post_message:     text_element('post_message'),
        items_attributes: elements('Item').map { |item| InvoiceItemNode.new(item, @tax).to_h }
      }
    end
  end

  class InvoiceItemNode < XmlNode
    def to_h
      @node.to_h.merge 'unit_price' => monetize('unit_price')
    end
  end

  def self.reset_all
    reset Stock
    reset Invoice
    reset Delivery
    reset Price
    reset Customer
    reset Product
    reset Seller
  end

  def self.import_all(with_delete: true)
    reset_all if with_delete

    ActiveRecord::Base.logger.level = 1

    puts import_sellers
    puts import_products

    puts import_customers_all
    puts deactivate_old_customers

    puts link_deliveries_to_invoices
    puts link_invoice_items_to_products
    puts generate_initial_stocks
    puts generate_stocks_for_invoices
  end

  def self.import_sellers
    puts __method__

    Seller.create! xml_data('sellers', 'Seller').map(&:to_h)
    Seller.count
  end

  def self.import_products
    puts __method__

    Product.create! xml_data('products', 'Product').map(&:to_h)
    Setting.product_categories = Product.pluck(:category).uniq.compact.sort
    Product.count
  end

  def self.import_customers_all(with_delete: true)
    puts __method__
    if with_delete
      reset Stock
      reset Invoice
      reset Delivery
      reset Price
      reset Customer
    end

    Setting.seller_map = Seller.all.map { |s| [s.short, s.id] }.to_h
    Setting.product_map = Product.all.map { |p| [p.number, p.id] }.to_h

    file_name = Rails.root.join('db', 'seeds', 'customers.xml')
    doc = Nokogiri::XML(File.open(file_name)).xpath('//Customer')

    doc.each do |customer_xml|
      customer_node = CustomerNode.new customer_xml
      customer = Customer.create! customer_node.to_h
      customer_node.prices.each do |price|
        begin
          customer.prices.create! price
        rescue ActiveRecord::RecordInvalid => e
          puts "#{e.message}: #{customer.name} #{e.record}"
        end
      end
      customer_node.deliveries.each do |delivery|
        begin
          customer.deliveries.create! delivery
        rescue ActiveRecord::RecordInvalid => e
          puts "#{e.message}: LSN #{e.record.number}"
        end
      end
      customer_node.invoices.each do |invoice|
        begin
          customer.invoices.create! invoice
        rescue ActiveRecord::RecordInvalid => e
          puts "#{e.message}: RN #{e.record.number}"
        end
      end
    end

    reset_pk Customer
    Customer.count
  end

  def self.deactivate_old_customers
    old_customers = Delivery.select(:customer_id).group(:customer_id).having('max(date) < ?', 5.month.ago)
    Customer.where(id: old_customers).update_all(archived: true)
    Customer.active.count
  end

  def self.xml_data(file_name, node_name = nil)
    node_name ||= file_name
    file_name = Rails.root.join('db', 'seeds', "#{file_name}.xml")
    Nokogiri::XML(File.open(file_name)).xpath("//#{node_name}")
  end

  def self.reset(model)
    model.delete_all
    reset_pk model
  end

  def self.reset_pk(model)
    ActiveRecord::Base.connection.reset_pk_sequence!(model.table_name)
  end

  def self.link_deliveries_to_invoices
    puts __method__
    Delivery.transaction do
      Delivery.on_account.where.not(invoice_number: nil).each do |delivery|
        invoice = Invoice.find_by number: delivery.invoice_number
        delivery.update invoice_id: invoice.id if invoice
      end
    end
    nil
  end

  def self.link_invoice_items_to_products
    puts __method__
    products = Product.all.each_with_object({}) { |p, products| products[p.name] = p }

    InvoiceItem.all.each do |item|
      item.update product: products[item.name] if products[item.name]
    end
    nil
  end

  def self.generate_initial_stocks
    puts __method__
    Stock.transaction do
      Customer.all.each { |customer| customer.initialize_stock(20.years.ago).save }
    end
    nil
  end

  def self.generate_stocks_for_invoices
    puts __method__
    Stock.transaction do
      Customer.all.each do |customer|
        customer.invoices.order(:date).pluck(:date).uniq.each do |invoice_date|
          customer.calculate_new_stock(invoice_date).save
        end
      end
    end
    nil
  end

end

