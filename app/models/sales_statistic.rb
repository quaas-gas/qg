class SalesStatistic

  attr_reader :name, :date, :region, :product_group

  def initialize(name:, date:, product_group:, region: nil)
    @name          = name
    @date          = date
    @region        = region
    @product_group = product_group
  end

  def results
    result = {}
    detailed_report.rows.group_by(&:customer_category).each do |cust_cat, rows|
      result[cust_cat] = rows_to_hash rows
    end
    result[:sums] = rows_to_hash sums_report.rows
    @result = result
  end

  def product_categories_content
    Setting.product_cats['has_content'] & product_categories
  end

  def product_categories_fees
    Setting.product_cats['fees'] & product_categories
  end

  private

  def detailed_report
    groups = %i( customer_category product_category )
    DeliveryReport.new filter: base_filter, groups: groups, sums: [:total_content, :total_price]
  end

  def sums_report
    groups = %i( product_category )
    DeliveryReport.new filter: base_filter, groups: groups, sums: [:total_content, :total_price]
  end

  def rows_to_hash(rows)
    res = rows.each_with_object({}) do |row, hash|
      hash[row.product_category] = sum_hash row.total_content, row.total_price
    end
    res[:sum] = sum_hash(
      res.values.map { |val| val[:total_content] }.sum,
      res.values.map { |val| val[:total_price]   }.sum
    )
    res
  end

  def sum_hash(content, price)
    { total_content: content, total_price: price }
  end

  def product_categories
    @product_categories ||= @result.values.flat_map(&:keys).uniq
  end

  def base_filter
    filter = { date: @date, product_group: @product_group }
    filter[:region] = @region if @region.present?
    filter
  end

  def content
    groups = %i( customer_category product_category )
    filter = { has_content: true }.merge base_filter
    DeliveryReport.new filter: filter, groups: groups, sums: [:total_content]
  end

  def fees
    groups = %i( customer_category product_category )
    filter = { has_content: false }.merge base_filter
    DeliveryReport.new filter: filter, groups: groups, sums: [:total_price]
  end

  def prices
    DeliveryReport.new filter: base_filter, groups: %i(customer_category), sums: [:total_price]
  end
end
