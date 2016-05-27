class Invoice < ActiveRecord::Base
  belongs_to :customer, inverse_of: :invoices, required: true
  has_many :items, inverse_of: :invoice, class_name: 'InvoiceItem'
  has_many :deliveries, inverse_of: :invoice #, foreign_key: 'invoice_number'

  validates :number, presence: true, uniqueness: true

  NUMBER_SEPARATOR = '/'

  def self.next_number
    invoice = order(number: :desc).first
    if invoice
      year, counter = invoice.number.split NUMBER_SEPARATOR
      format_number year: year, counter: (counter.to_i + 1)
    else
      format_number
    end
  end

  def self.format_number(year: Date.current.year, counter: 1)
    [year, counter.to_s.rjust(3, '0')].join NUMBER_SEPARATOR
  end

  def total_price
    items.map(&:total_price).sum(Money.new 0)
  end

  def build_items_from_deliveries
    grouped_items = {}
    deliveries.each do |delivery|
      delivery.items.each do |item|
        id = [item.product_id, item.name, item.unit_price]
        grouped_items[id] ||= 0
        grouped_items[id] += item.count
      end
    end
    grouped_items.each do |id, item_count|
      product_id, name, unit_price = id
      name = name.present? ? name : Product.find(product_id).name
      items.build count: item_count, name: name, unit_price: unit_price
    end
  end

end
