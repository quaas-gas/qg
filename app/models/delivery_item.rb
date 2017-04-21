class DeliveryItem < ActiveRecord::Base
  belongs_to :delivery, inverse_of: :items
  belongs_to :product

  validates :unit_price, :count, presence: true

  before_save :set_sum_values

  register_currency :eu4net
  monetize :unit_price_cents
  monetize :total_price_cents

  def stock_diff
    return 0 unless product.in_stock
    count - count_back.to_i
  end

  def total_content
    total_content_in_g.to_i / 1000
  end

  private

  def set_sum_values
    self.count ||= 0
    self.total_price = count * unit_price
    return unless product.present?
    self.total_content_in_g = (count * product.content * 1000)
    self.product_category   = product.category
    self.product_group      = product.group
  end
end
