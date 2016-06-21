class Price < ActiveRecord::Base
  belongs_to :customer, required: true, inverse_of: :prices
  belongs_to :product, required: true

  scope :in_stock, -> { where in_stock: true }

  monetize :price_cents, with_model_currency: :price_currency
  monetize :discount_cents, with_model_currency: :discount_currency

  def per_content
    price.exchange_to('EU4NET') / product.content
  end

  def per_content_unit
    "#{price.symbol} / #{product.unit}"
  end
end
