require 'benchmark'

module Importer

  class XmlNode
    def initialize(node, tax = nil)
      @node = node
      @tax = tax.nil? ? bool('tax') : tax
    end

    def attr(name)
      @node.attributes[name]&.text
    end

    def text_element(name)
      text = @node.elements.find { |el| el.name == name }&.text
      text = text.split("\n").map(&:strip).join("\n") if text.present?
      text
    end

    def elements(name)
      @node.elements.select { |el| el.name == name }
    end

    def monetize(field)
      val = attr(field) || 0
      Money.from_amount val.to_f, (@tax ? 'EU4TAX' : 'EU4NET')
    end

    def bool(field)
      attr(field) == '1'
    end
  end

  class CustomerNode < XmlNode
    def to_h
      customer = @node.to_h.slice 'id', 'tax', 'salut', 'name', 'name2', 'city', 'zip', 'phone',
                             'gets_invoice', 'has_stock', 'region'
      customer[:category] = attr('kind')
      customer[:invoice_address] = text_element('invoice_address')
      customer
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
        number:           attr('number_show'),
        seller_id:        Setting.seller_map[attr('seller')],
        date:             Date.strptime(attr('date'), '%m/%d/%Y'),
        invoice_number:   attr('invoice_number'),
        tax:              @tax,
        on_account:       bool('on_account'),
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

  def self.xml_data(file_name, node_name = nil)
    node_name ||= file_name
    file_name = Rails.root.join('db', 'seeds', "#{file_name}.xml")
    Nokogiri::XML(File.open(file_name)).xpath("//#{node_name}")
  end

  def self.reset(*models)
    models.each { |model| model.delete_all }
    reset_pk *models
  end

  def self.reset_pk(*models)
    models.each { |model| ActiveRecord::Base.connection.reset_pk_sequence!(model.table_name) }
  end

  def self.import_all(with_delete: true)
    reset Stock, Invoice, Delivery, Price, Customer, Product, Seller if with_delete

    ActiveRecord::Base.logger.level = 1

    time = Benchmark.measure do
      import_xml
      deactivate_old_customers
      link_deliveries_to_invoices
      link_invoice_items_to_products
      generate_initial_stocks
      generate_stocks_for_invoices
      rebuild_search_index
    end
    puts time.real
  end

  def self.import_xml
    puts __method__

    Seller.create! xml_data('sellers', 'Seller').map(&:to_h)
    Product.create! xml_data('products', 'Product').map(&:to_h)
    Setting.product_categories = Product.pluck(:category).uniq.compact.sort

    Setting.seller_map  = Seller.all.map { |s| [s.short, s.id] }.to_h
    Setting.product_map = Product.all.map { |p| [p.number, p.id] }.to_h

    time = Benchmark.measure do
      PgSearch.disable_multisearch do
        xml_data('qg-customers-since-2012', 'Customer').each do |customer_xml|
          customer_node = CustomerNode.new customer_xml
          customer = Customer.create! customer_node.to_h
          customer_node.prices.each     { |price|    create_price    customer, price }
          customer_node.deliveries.each { |delivery| create_delivery customer, delivery }
          customer_node.invoices.each   { |invoice|  create_invoice  customer, invoice }
        end
      end
    end
    puts time.real

    Setting.customer_categories = Customer.uniq.pluck(:kind).sort

    reset_pk Customer
    puts "   customers: #{Customer.count}, deliveries: #{Delivery.count}, invoices: #{Invoice.count}"
  end

  def self.create_price(customer, price)
    customer.prices.create! price
  rescue ActiveRecord::RecordInvalid => e
    puts "#{e.message}: #{customer.name} #{e.record}"
  end

  def self.create_delivery(customer, delivery)
    customer.deliveries.create! delivery
  rescue ActiveRecord::RecordInvalid => e
    puts "#{e.message}: LSN #{e.record.number}"
  end

  def self.create_invoice(customer, invoice)
    customer.invoices.create! invoice
  rescue ActiveRecord::RecordInvalid => e
    puts "#{e.message}: RN #{e.record.number}"
  end

  def self.deactivate_old_customers
    print __method__, ' '
    old_customers = Delivery.select(:customer_id).group(:customer_id).having('max(date) < ?', 5.month.ago)
    Customer.where(id: old_customers).update_all(archived: true)
    puts Customer.active.count
  end

  def self.link_deliveries_to_invoices
    puts __method__
    Delivery.transaction do
      Delivery.on_account.where.not(invoice_number: nil).each do |delivery|
        next if delivery.invoice_number.blank?
        if (invoice = Invoice.find_by number: delivery.invoice_number)
          delivery.update invoice_id: invoice.id
        else
          puts "No invoice with number #{delivery.invoice_number}, delivery #{delivery.number}"
        end
      end
    end
  end

  def self.link_invoice_items_to_products
    puts __method__
    products = Product.all.each_with_object({}) { |p, products| products[p.name] = p }
    InvoiceItem.all.each do |item|
      item.update product: products[item.name] if products[item.name]
    end
  end

  def self.generate_initial_stocks
    puts __method__
    Stock.transaction do
      Customer.all.each { |customer| customer.initialize_stock(20.years.ago).save }
    end
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
  end

  def self.rebuild_search_index
    puts __method__
    PgSearch::Multisearch.rebuild(Customer)
    PgSearch::Multisearch.rebuild(Delivery)
    PgSearch::Multisearch.rebuild(Invoice)
    nil
  end

end
