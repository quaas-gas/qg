class DeliveryItem < ActiveRecord::Base
  belongs_to :delivery
  belongs_to :product

  validates :unit_price, :count, presence: true

  default_scope { order(:product_id) }

  monetize :unit_price_cents, with_model_currency: :unit_price_currency

  def total_price
    unit_price * count
  end
end
