class Statistic < ActiveRecord::Base
  validates :name, presence: true

  attr_reader :result, :y_sums

  TIME_RANGES = %w(this_week last_week this_month last_month this_year last_year)
  GROUPING    = %w(region customer_category product_category time)
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
    when 'time'
      (1..12).to_a
    end
  end

  def items_scope(only: nil)
    scope = DeliveryItem
      .joins(:product, delivery: :customer)
      .where('deliveries.date >= ?', start_date)
      .where('deliveries.date <= ?', end_date)
    scope = if only
      scope.group(group_option(only))
    else
      scope.group(group_option(:y), group_option(:x))
    end
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
    @y_sums = {}
    sums = items_scope.sum(sum_option)
    sums.each do |(first, second), value|
      @result[first] ||= {}
      second = second.to_i if grouping_x == 'time' # grouping by month returns float as key
      @result[first][second] = cast_val value
    end
    @result[:total] = items_scope(only: :x).sum(sum_option)
    if grouping_x == 'time' # grouping by month returns float as key
      @result[:total].keys.each { |key| @result[:total][key.to_i] = @result[:total].delete key }
    end
    @result[:total].each { |label, value| @result[:total][label] = cast_val value }
    @y_sums[:content] = items_scope(only: :y).sum('count * products.content')
    @y_sums[:net]     = items_scope(only: :y).sum('count * unit_price_cents')
    @y_sums[:content][:total] = @y_sums[:content].values.sum
    @y_sums[:net][:total] = @y_sums[:net].values.sum
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
      when 'time' then 'extract(month from deliveries.date)'
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
      when 'last_year'  then 1.year.ago.to_date.beginning_of_year
    end
  end

  def end_date
    case time_range_relative
      when 'this_week'  then Date.current.end_of_week
      when 'last_week'  then 1.week.ago.to_date.end_of_week
      when 'this_month' then Date.current.end_of_month
      when 'last_month' then 1.month.ago.to_date.end_of_month
      when 'this_year'  then Date.current.end_of_year
      when 'last_year'  then 1.year.ago.to_date.end_of_year
    end
  end

end
