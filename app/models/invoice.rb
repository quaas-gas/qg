class Invoice < ActiveRecord::Base
  belongs_to :customer, inverse_of: :invoices, required: true
  has_many :items, inverse_of: :invoice, class_name: 'InvoiceItem'

  validates :number, presence: true, uniqueness: true

  def total_price
    items.map(&:total_price).sum(Money.new 0)
  end

end
