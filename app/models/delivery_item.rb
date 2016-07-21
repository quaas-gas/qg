class DeliveryItem < ActiveRecord::Base
  belongs_to :delivery, inverse_of: :items
  belongs_to :product

  validates :unit_price, :count, presence: true

  register_currency :eu4net
  monetize :unit_price_cents

  def stock_diff
    return 0 unless product.in_stock
    count - count_back
  end

  def total_price
    unit_price * (count || 0)
  end

  def total_content
    product.content * (count || 0)
  end
end
