class InvoiceItem < ActiveRecord::Base
  include Comparable
  belongs_to :invoice, inverse_of: :items
  belongs_to :product

  monetize :unit_price_cents, with_model_currency: :unit_price_currency

  def total_price
    unit_price * (count || 0)
  end

  def <=>(other)
    if product.present?
      if other.product.present?
        product.number <=> other.product.number
      else
        -1
      end
    else
      other.product.present? ? 1 : 0
    end
  end

end
