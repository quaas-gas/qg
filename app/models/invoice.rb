class Invoice < ActiveRecord::Base
  belongs_to :customer, inverse_of: :invoices, required: true

  validates :number, presence: true, uniqueness: true
end
