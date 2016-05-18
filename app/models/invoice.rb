class Invoice < ActiveRecord::Base
  belongs_to :customer, inverse_of: :invoices, required: true
  has_many :items, inverse_of: :invoice, class_name: 'InvoiceItem'

  validates :number, presence: true, uniqueness: true

  NUMBER_SEPARATOR = '/'

  def self.next_number
    invoice = order(number: :desc).first
    if invoice
      year, counter = invoice.number.split NUMBER_SEPARATOR
      format_number year: year, counter: (counter.to_i + 1)
    else
      format_number
    end
  end

  def self.format_number(year: Date.current.year, counter: 1)
    [year, counter.to_s.rjust(3, '0')].join NUMBER_SEPARATOR
  end

  def total_price
    items.map(&:total_price).sum(Money.new 0)
  end

end
