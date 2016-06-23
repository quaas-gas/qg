class Stock
  attr_reader :customer, :date
  def initialize(customer, date = Date.current)
    @customer = customer
    @date = date
    @stock = stock_at date
  end

  def [](product_number)
    @stock[product_number]
  end

  def initial?
    date == initial_date
  end

  def current?
    date == Date.current
  end

  def initial_date
    customer.initial_stock_date
  end

  def stock_at(date = Date.current)
    change = stock_change date
    customer.prices.in_stock.includes(:product).each_with_object({}) do |price, stock|
      product_number = price.product.number
      stock[product_number] = price.initial_stock_balance + (change[product_number] || 0)
    end
  end

  def stock_change(date = Date.current)
    customer_deliveries = Delivery.where(customer: customer)
      .where('date > ?', initial_date || 20.years.ago).where('date <= ?', date)
    DeliveryItem.where(delivery: customer_deliveries).joins(:product).where('products.in_stock')
      .group('products.number').sum('count - count_back')
  end
end
