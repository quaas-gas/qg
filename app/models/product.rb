class Product < ActiveRecord::Base

  has_many :delivery_items

  validates :number, presence: true, uniqueness: true

  scope :in_stock, -> { where in_stock: true }

  monetize :price_cents, with_model_currency: :price_currency

end
