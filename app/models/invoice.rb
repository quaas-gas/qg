class Invoice < ActiveRecord::Base
  include PgSearch

  belongs_to :customer, inverse_of: :invoices, required: true
  has_many :items, inverse_of: :invoice, class_name: 'InvoiceItem'
  has_many :deliveries, inverse_of: :invoice, dependent: :nullify #, foreign_key: 'invoice_number'

  validates :number, presence: true, uniqueness: true
  validate :validate_items

  multisearchable against: [:number, :pre_message, :post_message]

  accepts_nested_attributes_for :items,
                                reject_if: lambda { |attributes|
                                  attributes['count'].blank? || attributes['unit_price'].blank?
                                }

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
    grouped_items.each do |(product_id, name, unit_price), item_count|
      name = name.present? ? name : Product.find(product_id).name
      item = { count: item_count, name: name, unit_price: unit_price }
      item[:product_id] = product_id if product_id.present?
      items.build item
    end
    position = 0
    items.sort.each { |item| item.position = (position += 1) }
  end

  def previous
    self.class.where(customer: self.customer).where.not(id: id).order(date: :desc).first
  end

  private

  def validate_items
    errors.add(:items, :too_few) if items.empty?
  end
end
