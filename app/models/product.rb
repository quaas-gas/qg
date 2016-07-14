class Product < ActiveRecord::Base

  has_many :delivery_items

  validates :number, presence: true, uniqueness: true

  scope :in_stock, -> { where in_stock: true }

  register_currency :eu4net
  monetize :price_cents

end
