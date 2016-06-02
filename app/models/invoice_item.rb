class InvoiceItem < ActiveRecord::Base
  belongs_to :invoice, inverse_of: :items
  belongs_to :product

  monetize :unit_price_cents, with_model_currency: :unit_price_currency

  def total_price
    unit_price * (count || 0)
  end

end
