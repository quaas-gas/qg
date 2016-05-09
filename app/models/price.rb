class Price < ActiveRecord::Base
  belongs_to :customer, required: true, inverse_of: :prices
  belongs_to :product, required: true

  monetize :price_cents, with_model_currency: :price_currency
  monetize :discount_cents, with_model_currency: :discount_currency
end
