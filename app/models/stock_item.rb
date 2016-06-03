class StockItem < ActiveRecord::Base
  belongs_to :stock, required: true, inverse_of: :items
  belongs_to :product, required: true

  validates :count, presence: true
end
