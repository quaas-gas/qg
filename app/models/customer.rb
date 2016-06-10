class Customer < ActiveRecord::Base
  include PgSearch

  has_many :deliveries, inverse_of: :customer
  # has_many :delivery_items, through: :deliveries, source: :items
  has_many :prices, -> { includes(:product).order('products.number') }, inverse_of: :customer
  has_many :invoices, inverse_of: :customer
  has_many :open_deliveries, -> { where(on_account: true, invoice_id: nil) }, class_name: 'Delivery'
  has_many :stocks, inverse_of: :customer

  multisearchable against: [:id, :salut, :name, :name2, :street, :city, :kind, :invoice_address]

  accepts_nested_attributes_for :prices,
                                allow_destroy: true,
                                reject_if: lambda { |attributes|
                                  if attributes['id'].present?
                                    attributes['price'].blank?
                                  else
                                    attributes['product_id'].blank? || attributes['price'].blank?
                                  end
                                }

  validates :name, :city, presence: true

  scope :archived, -> { where(archived: true)  }
  scope :active,   -> { where(archived: false) }
  scope :tax,      -> { where(tax: true)  }
  scope :nontax,   -> { where(tax: false) }

  def last_invoice
    @last_invoice ||= invoices.order(number: :desc).first
  end

  def generate_next_invoice(delivery_ids)
    invoice_hash = {
      number: Invoice.next_number,
      tax: tax,
      address: invoice_address,
      date: Date.current,
      deliveries: open_deliveries.where(id: delivery_ids)
    }
    invoice_hash.merge! last_invoice.attributes.slice('pre_message', 'post_message') if last_invoice
    invoices.build(invoice_hash) { |invoice| invoice.build_items_from_deliveries }
  end

  def history(months = 4)
    date        = months.month.ago.to_date.at_end_of_month
    _deliveries = deliveries.includes(:items).where('date > ?', date).order(date: :desc).to_a
    _invoices   = invoices.  includes(:items).where('date > ?', date).order(date: :desc).to_a
    _stocks     = stocks.    includes(:items).where('date > ?', date).order(date: :desc).to_a
    (_stocks + _deliveries + _invoices).sort do |a, b|
      res = b.date <=> a.date
      (res == 0) ? b.class.name <=> a.class.name : res
    end
  end

  def calculate_new_stock(date)
    l_stock = last_stock
    raise "date #{date} must be greater than last stock date (#{l_stock.date})" if date < l_stock.date

    initialize_stock(date, last_stock: l_stock).tap { |stock| stock.calculate_items }
  end

  def initialize_stock(date, last_stock: nil)
    stocks.build(date: date).tap { |stock| stock.initialize_items last_stock: last_stock }
  end

  def current_stock
    return nil if stocks.empty?
    calculate_new_stock Date.current
  end

  def last_stock
    stocks.includes(:items).order(date: :desc).first
  end

  def initial_stock
    stocks.includes(:items).order(date: :asc).first
  end
end
