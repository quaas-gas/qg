class Stock < ActiveRecord::Base
  belongs_to :customer, inverse_of: :stocks, required: true
  has_many :items, class_name: 'StockItem', inverse_of: :stock

  validates :date, presence: true

  accepts_nested_attributes_for :items

  def initialize_items(last_stock: nil)
    customer.prices.each do |price|
      last_item = last_stock&.items&.find { |i| i.product_id == price.product_id }
      items.build product_id: price.product_id, count: (last_item&.count).to_i
    end
  end

  def calculate_items
    customer.deliveries.includes(:items)
      .where('date > ?', customer.last_stock.date).where('date <= ?', date).each do |delivery|
      items.each do |item|
        dev_item   = delivery.items.find { |i| i.product_id == item.product_id }
        item.count = item.count + dev_item.count - dev_item.count_back if dev_item
      end
    end
  end
end
