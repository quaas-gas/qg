class Statistic < ActiveRecord::Base
  validates :name, presence: true

  attr_reader :result

  TIME_RANGES = %w(week month quart year).flat_map do |period|
    %w(this last).map { |this_last| "#{this_last}_#{period}" }
  end + ['custom']
  GROUPING    = %w(region customer_category product_category time time_year seller)
  FILTERS     = %w(regions customer_categories product_categories)
  SUMS        = %w(content net tax)
  SUM_TYPES   = %i(content net tax net_content)

  def time_range_relative
    time_range['relative']
  end

  %w(x y).each { |dim| define_method("grouping_#{dim}") { grouping[dim] } }

  FILTERS.each { |filter_name| define_method(filter_name) { filter[filter_name] || [] } }

  def labels_for(x_or_y)
    hash = (x_or_y == :x) ? @result[:content] : @result
    hash.keys.reject { |key| key.is_a? Symbol }.sort
  end

  def label_for(x_or_y, label)
    case grouping[x_or_y.to_s]
      when 'time' then I18n.t('date.abbr_month_names')[label]
      when 'time_year' then label.to_i
    else label
    end
  end

  def items_scope(only: nil)
    scope = DeliveryItem
      .joins(:product, delivery: [:customer, :seller])
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
    @result = sums_for(:x)
    items_scope.sum(sum_option).each do |(y, x), value|
      @result[y] ||= {}
      @result[y][x] = cast_val value
    end
    y_sums = sums_for(:y)
    @result.each do |y_label, row|
      SUM_TYPES.each { |sum_type| row[sum_type] = y_sums[sum_type][y_label] }
    end
    @result
  end

  def sums_for(x_or_y)
    sums = {
      content:     items_scope(only: x_or_y).sum(sum_option(type: 'content')),
      net:         items_scope(only: x_or_y).sum(sum_option(type: 'tax')),
      tax:         {},
      net_content: {},
    }
    sums[:net].each do |label, value|
      sums[:net][label] = cast_val value, type: 'net'
      sums[:tax][label] = cast_val value, type: 'tax'
      sums[:net_content][label] = (sums[:net][label] / sums[:content][label]) if sums[:content][label] != 0
    end
    %i(content net tax).each { |sum_type| sums[sum_type][:total] = sums[sum_type].values.sum }
    sums
  end

  def cast_val(value, type: sums_of)
    return value if type == 'content'
    value = Money.new(value)
    return value.exchange_to('EURNET') if type == 'net'
    value.exchange_to('EU4TAX').exchange_to('EURTAX')
  end

  def group_option(x_or_y)
    case grouping[x_or_y.to_s]
      when 'region'            then 'customers.region'
      when 'customer_category' then 'customers.category'
      when 'product_category'  then 'products.category'
      when 'time'              then 'extract(month from deliveries.date)'
      when 'time_year'         then 'extract(year from deliveries.date)'
      when 'seller'            then 'sellers.short'
    end
  end

  def sum_option(type: sums_of)
    return 'count * products.content' if type == 'content'
    'count * unit_price_cents'
  end

  def start_date
    date_range.first
  end

  def end_date
    date_range.last
  end

  def date_range
    return [custom_date('start'), custom_date('end')] if time_range_relative == 'custom'
    today      = Date.current
    last_week  = 1.week.ago.to_date
    last_month = 1.month.ago.to_date
    last_quart = 3.month.ago.to_date
    last_year  = 1.year.ago.to_date
    case time_range_relative
      when 'this_week'  then [today.     beginning_of_week,    today.     end_of_week]
      when 'last_week'  then [last_week. beginning_of_week,    last_week. end_of_week]
      when 'this_month' then [today.     beginning_of_month,   today.     end_of_month]
      when 'last_month' then [last_month.beginning_of_month,   last_month.end_of_month]
      when 'this_quart' then [today.     beginning_of_quarter, today.     end_of_quarter]
      when 'last_quart' then [last_quart.beginning_of_quarter, last_quart.end_of_quarter]
      when 'this_year'  then [today.     beginning_of_year,    today.     end_of_year]
      when 'last_year'  then [last_year. beginning_of_year,    last_year. end_of_year]
    end
  end

  def custom_date(start_or_end)
    Date.parse(time_range["#{start_or_end}_date"])
  end

end
