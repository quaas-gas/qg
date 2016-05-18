class Customer < ActiveRecord::Base
  include PgSearch

  has_many :deliveries, inverse_of: :customer
  has_many :prices, -> { includes(:product).order('products.number') }, inverse_of: :customer
  has_many :invoices, inverse_of: :customer
  has_many :open_deliveries, -> { where(on_account: true, invoice_number: nil) }, class_name: 'Delivery'

  multisearchable against: [:salut, :name, :name2, :street, :city, :kind, :invoice_address]

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
  scope :own,      -> { where(own_customer: true) }


  def generate_next_invoice(delivery_ids)
    invoice_hash = {
      number: Invoice.next_number,
      tax: tax,
      address: invoice_address,
      date: Date.current,
      deliveries: open_deliveries.where(id: delivery_ids)
    }
    last_invoice = invoices.order(number: :desc).first
    if last_invoice
      invoice_hash[:pre_message] = last_invoice.pre_message
      invoice_hash[:post_message] = last_invoice.post_message
    end
    invoices.build invoice_hash do |invoice|
      invoice.build_items_from_deliveries
    end
  end
end
