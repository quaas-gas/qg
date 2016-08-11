class Customer < ActiveRecord::Base
  include PgSearch

  has_many :deliveries, inverse_of: :customer
  # has_many :delivery_items, through: :deliveries, source: :items
  has_many :prices, -> { includes(:product).order('products.number') }, inverse_of: :customer
  has_many :invoices, inverse_of: :customer
  has_many :open_deliveries, -> { where(on_account: true, invoice_id: nil) }, class_name: 'Delivery'

  multisearchable against: [:id, :salut, :name, :name2, :street, :city, :category, :invoice_address]

  accepts_nested_attributes_for :prices,
                                allow_destroy: true,
                                reject_if: lambda { |attributes|
                                  unless attributes['in_stock'].present?
                                    if attributes['id'].present?
                                      attributes['price'].blank?
                                    else
                                      attributes['product_id'].blank? || attributes['price'].blank?
                                    end
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
    _deliveries = deliveries.includes(items: :product).where('date > ?', date).order(date: :desc).to_a
    _invoices   = invoices.  includes(items: :product).where('date > ?', date).order(date: :desc)
    _stocks = _invoices.where('date >= ?', initial_stock_date).map { |invoice| Stock.new self, invoice.date }
    _stocks << Stock.new(self, initial_stock_date) if _stocks.none?(&:initial?)
    [Stock.new(self, Date.current)] + (_deliveries + _invoices.to_a + _stocks).sort do |a, b|
      res = b.date <=> a.date
      (res == 0) ? b.class.name <=> a.class.name : res
    end
  end

  def stock_products
    @stock_products ||= prices.in_stock.includes(:product).map(&:product).to_a
  end

  def display_name
    "#{name}, #{city}, #{street}"
  end

end
