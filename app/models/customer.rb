# frozen_string_literal: true

## Customer
class Customer < ActiveRecord::Base
  include PgSearch

  has_many :deliveries, inverse_of: :customer
  # has_many :delivery_items, through: :deliveries, source: :items
  has_many :prices, -> { includes(:product).order('products.number') }, inverse_of: :customer
  has_many :invoices, inverse_of: :customer
  has_many :open_deliveries, -> { where(on_account: true, invoice_id: nil) }, class_name: 'Delivery'

  multisearchable against: %i[id salut name name2 street city category invoice_address]

  accepts_nested_attributes_for :prices,
                                allow_destroy: true,
                                reject_if: lambda { |attributes|
                                  if attributes['in_stock'].blank?
                                    if attributes['id'].present?
                                      attributes['price'].blank?
                                    else
                                      attributes['product_id'].blank? || attributes['price'].blank?
                                    end
                                  end
                                }

  validates :name, :city, presence: true

  scope(:archived, -> { where(archived: true)  })
  scope(:active,   -> { where(archived: false) })
  scope(:tax,      -> { where(tax: true)  })
  scope(:nontax,   -> { where(tax: false) })

  def last_invoice
    @last_invoice ||= invoices.order(number: :desc).first
  end

  def generate_next_invoice(delivery_ids)
    invoice_hash = {
      number:     Invoice.next_number,
      tax:        tax,
      address:    invoice_address,
      date:       Date.current,
      deliveries: open_deliveries.where(id: delivery_ids)
    }
    invoice_hash.merge! last_invoice.attributes.slice('pre_message', 'post_message') if last_invoice
    invoices.build(invoice_hash, &:build_items_from_deliveries)
  end

  def history(months = 4)
    date = months.month.ago.to_date.at_end_of_month
    history_items(date).sort do |a, b|
      res = b.date <=> a.date
      res.zero? ? b.class.name <=> a.class.name : res
    end
  end

  def stock_products
    @stock_products ||= prices.in_stock.includes(:product).map(&:product).to_a
  end

  def display_name
    "#{name}, #{city}, #{street}"
  end

  private

  def history_items(date)
    last_deliveries = deliveries_since(date).to_a
    last_invoices   = invoices_since(date).to_a
    last_stocks     = invoice_stocks_since(date)
    last_stocks << Stock.new(self, initial_stock_date) if last_stocks.none?(&:initial?)
    [Stock.new(self, Date.current)] + (last_deliveries + last_invoices + last_stocks)
  end

  def deliveries_since(date)
    deliveries.includes(items: :product).where('date > ?', date).order(date: :desc)
  end

  def invoices_since(date)
    invoices.includes(items: :product).where('date > ?', date).order(date: :desc)
  end

  def invoice_stocks_since(date)
    invoices_since(date).where('date >= ?', initial_stock_date).map do |invoice|
      Stock.new self, invoice.date
    end
  end
end
