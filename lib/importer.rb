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

    def elements(name, scope: nil)
      base = scope ? @node.elements.find { |e| e.name == scope } : @node
      base.elements.select { |el| el.name == name }
    end

    def monetize(field)
      val = attr(field) || 0
      m = Money.from_amount val.to_f, (@tax ? 'EU4TAX' : 'EU4NET')
      m.exchange_to 'EU4NET'
    end

    def bool(field)
      attr(field) == '1'
    end

    def date(field)
      val = attr(field)
      return nil unless val.present?
      Date.strptime(val, '%m/%d/%Y')
    end
  end

  class CustomerNode < XmlNode
    def to_h
      customer                      = @node.to_h.slice 'id', 'salut', 'name', 'name2', 'street', 'city', 'zip', 'phone', 'region'
      customer[:has_stock]          = bool 'has_stock'
      customer[:gets_invoice]       = bool 'gets_invoice'
      # customer[:tax]                = customer[:gets_invoice] ? false : bool('tax')
      customer[:tax]                = bool 'tax'
      customer[:category]           = attr('kind')
      customer[:invoice_address]    = text_element('invoice_address')
      customer[:initial_stock_date] = date('last_stock_date') || Date.new(2000)
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
        product_id: Setting.product_map[attr('product_number')][:id],
        price:    monetize('price'),
        discount: monetize('discount'),
        active:   true,
        in_stock: true,
        initial_stock_balance: attr('stock_current').to_i
      }
    end
  end

  class DeliveryNode < XmlNode
    def to_h
      {
        number:           attr('number_show'),
        seller_id:        Setting.seller_map[attr('seller')],
        date:             date('date'),
        invoice_number:   attr('invoice_number'),
        tax:              @tax,
        on_account:       bool('on_account'),
        items_attributes: elements('Item').map { |item| DeliveryItemNode.new(item, @tax).to_h }
      }
    end
  end

  class DeliveryItemNode < XmlNode
    def to_h
      product = Setting.product_map[attr('product_number')]
      puts "no product for '#{attr('product_number')}'" unless product
      {
        product_id: (product ? product[:id] : nil),
        name:       (product ? product[:name] : ''),
        count:      attr('count'),
        count_back: attr('count_back'),
        unit_price: Money.from_amount((attr('unit_price_net') || 0).to_f, 'EU4NET')
      }
    end
  end

  class InvoiceNode < XmlNode
    def to_h
      {
        number:           attr('number'),
        date:             date('date'),
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

  class ReportNode < XmlNode
    def to_h
      {
        name: attr('name'),
        in_menu: bool('in_menu'),
        products: elements('product').map(&:text),
        product_categories: elements('product_category').map(&:text),
        content_product_categories: elements('content_product_category').map(&:text)
      }
    end
  end

  class StatisticNode < XmlNode
    def to_h
      {
        name: attr('name'),
        sums_of: attr('sums_of'),
        time_range: { relative: attr('time_range_relative') },
        grouping: { x: attr('grouping_x'), y: attr('grouping_y') },
        filter: {
          regions: elements('region', scope: 'filter').map(&:text),
          # regions: @node['filter'].elements.select { |el| el.name == name },
          product_categories: elements('product_category', scope: 'filter').map(&:text),
          # product_categories: @node.elements.find{|e| e.name == 'filter'}.elements.select {|e| e.name == 'product_category' }.map(&:text),
          customer_categories: elements('customer_category', scope: 'filter').map(&:text)
        }
      }
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

  def self.import_all(with_delete: true, from_year: 2016)
    log_level = ActiveRecord::Base.logger.level
    ActiveRecord::Base.logger.level = 1

    reset Invoice, Delivery, Price, Customer, Product, Seller, Report, Statistic if with_delete

    time = Benchmark.measure do
      import_xml from_year
      deactivate_old_customers
      link_deliveries_to_invoices
      link_invoice_items_to_products
      rebuild_search_index
      generate_reports_and_statstics
    end
    puts time.real

    ActiveRecord::Base.logger.level = log_level
  end

  def self.import_xml(year)
    puts __method__

    Report.create xml_data('reports', 'Report').map{ |node| ReportNode.new(node).to_h }
    Statistic.create xml_data('statistics', 'Statistic').map{ |node| res = StatisticNode.new(node).to_h; puts res; res }

    Seller.create! xml_data('sellers', 'Seller').map(&:to_h)
    Product.create! xml_data('products', 'Product').map(&:to_h)
    Setting.product_categories!

    Setting.seller_map  = Seller.all.map { |s| [s.short, s.id] }.to_h
    Setting.product_map = Product.all.map { |p| [p.number, { id: p.id, name: p.name }] }.to_h

    time = Benchmark.measure do
      PgSearch.disable_multisearch do
        xml_data("qg-customers-since-#{year}", 'Customer').each do |customer_xml|
          customer_node = CustomerNode.new customer_xml
          customer = Customer.create! customer_node.to_h
          customer_node.prices.each     { |price|    create_price    customer, price }
          customer_node.deliveries.each { |delivery| create_delivery customer, delivery }
          customer_node.invoices.each   { |invoice|  create_invoice  customer, invoice }
          print '.'
        end
      end
    end
    puts '', time.real

    # Customer.where(gets_invoice: true).update_all tax: false

    Setting.customer_categories!

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
    puts "#{e.message}: LSN #{e.record.number} #{e.record.date} #{e.record.customer.name}"
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

  def self.rebuild_search_index
    puts __method__
    [Customer, Delivery, Invoice].each { |model| PgSearch::Multisearch.rebuild model }
    nil
  end

  def self.generate_reports_and_statstics
    puts __method__
    Report.create name: 'Gasbuch Propan', products:
    nil
  end

end
