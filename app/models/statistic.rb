class Statistic < ActiveRecord::Base
  validates :name, presence: true

  attr_reader :result

  TIME_RANGES = %w(this_week last_week this_month last_month this_year last_year)
  GROUPING    = %w(region customer_category product_category)
  SUMS        = %w(content net tax)

  def time_range_relative
    time_range['relative']
  end

  def grouping_x
    grouping['x']
  end

  def grouping_y
    grouping['y']
  end

  def regions
    filter['regions'] || []
  end

  def customer_categories
    filter['customer_categories'] || []
  end

  def product_categories
    filter['product_categories'] || []
  end

  def labels_for(x_or_y)
    case grouping[x_or_y.to_s]
    when 'region'
      regions.any? ? regions : Setting.customer_regions
    when 'customer_category'
      customer_categories.any? ? customer_categories : Setting.customer_categories
    when 'product_category'
      product_categories.any? ? product_categories : Setting.product_categories
    end
  end

  def items_scope
    scope = DeliveryItem
      .joins(:product, delivery: :customer)
      .group(group_option(:y), group_option(:x))
      .where('deliveries.date >= ?', start_date)
      .where('deliveries.date <= ?', end_date)
    if regions.any? || customer_categories.any?
      customer_scope = Customer
      customer_scope = customer_scope.where(region: regions) if regions.any?
      customer_scope = customer_scope.where(category: customer_categories) if customer_categories.any?
      scope          = scope.where(delivery: Delivery.where(customer: customer_scope))
    end
    if product_categories.any?
      scope = scope.where(product: Product.where(category: product_categories))
    end
    scope
  end

  def calculate!
    @result = {}
    sums = items_scope.sum(sum_option)
    sums.each do |(first, second), value|
      @result[first] ||= {}
      @result[first][second] = cast_val value
    end
    @result.each do |_, row|
      row[:total] = row.values.sum
    end
    @result
  end

  def cast_val(value)
    case sums_of
      when 'content' then value
      when 'net' then Money.new(value).exchange_to('EURNET')
      when 'tax' then Money.new(value).exchange_to('EU4TAX').exchange_to('EURTAX')
    end
  end

  def group_option(x_or_y)
    case grouping[x_or_y.to_s]
      when 'region' then 'customers.region'
      when 'customer_category' then 'customers.category'
      when 'product_category' then 'products.category'
    end
  end

  def sum_option
    case sums_of
      when 'content' then 'count * products.content'
      when 'net', 'tax' then 'count * unit_price_cents'
    end
  end

  def start_date
    case time_range_relative
      when 'this_week'  then Date.current.beginning_of_week
      when 'last_week'  then 1.week.ago.to_date.beginning_of_week
      when 'this_month' then Date.current.beginning_of_month
      when 'last_month' then 1.month.ago.to_date.beginning_of_month
      when 'this_year'  then Date.current.beginning_of_year
      when 'last_year'  then 1.month.ago.to_date.beginning_of_year
    end
  end

  def end_date
    case time_range_relative
      when 'this_week'  then Date.current.end_of_week
      when 'last_week'  then 1.week.ago.to_date.end_of_week
      when 'this_month' then Date.current.end_of_month
      when 'last_month' then 1.month.ago.to_date.end_of_month
      when 'this_year'  then Date.current.end_of_year
      when 'last_month' then 1.month.ago.to_date.end_of_year
    end
  end

end
