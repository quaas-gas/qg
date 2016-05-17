class Customer < ActiveRecord::Base
  include PgSearch

  has_many :deliveries, inverse_of: :customer
  has_many :prices, -> { includes(:product).order('products.number') }, inverse_of: :customer
  has_many :invoices, inverse_of: :customer

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
end
