class InvoiceItem < ActiveRecord::Base
  include Comparable
  belongs_to :invoice, inverse_of: :items
  belongs_to :product

  register_currency :eu4net
  monetize :unit_price_cents

  def total_price
    unit_price * (count || 0)
  end

  def <=>(other)
    if product.present?
      other.product.present? ? product.number <=> other.product.number : -1
    else
      other.product.present? ? 1 : 0
    end
  end

end
