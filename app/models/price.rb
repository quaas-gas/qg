class Price < ActiveRecord::Base
  belongs_to :customer, required: true, inverse_of: :prices
  belongs_to :product, required: true

  scope :in_stock, -> { where in_stock: true }

  register_currency :eu4net
  monetize :price_cents
  monetize :discount_cents

  def per_content
    return nil if product.content == 0
    price.exchange_to('EU4NET') / product.content
  end

  def per_content_unit
    "#{price.symbol} / #{product.unit}"
  end
end
