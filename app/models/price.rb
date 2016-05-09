class Price < ActiveRecord::Base
  belongs_to :customer, required: true, inverse_of: :prices
  belongs_to :bottle, required: true

  monetize :price_cents
  monetize :discount_cents
end
