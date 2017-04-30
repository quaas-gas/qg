class Report < ActiveRecord::Base

  validates :name, :product_group, presence: true

  attr_reader :start_date, :end_date

  scope :in_menu, -> { where in_menu: true }

  def products
    @products ||= Product.where(group: product_group, in_stock: true).order(:number).all
  end

  def days
    Delivery.uniq.order(:date).where(date: @start_date..@end_date).pluck(:date)
  end

  def calculate!(start_date, end_date)
    @start_date, @end_date = start_date, end_date
    @_deliveries = ReportDelivery.get(product_group, @start_date, @end_date).group_by do |del|
      [del.date, del.on_account]
    end
    @_sums = {}

    product_counts.each do |day_on_account, sums|
      @_sums[day_on_account] = { products: sums.map { |del| [del.product_number, del.counts] }.to_h }
    end

    deliver_sums.each do |day_on_account, sums|
      @_sums[day_on_account] ||= {}
      @_sums[day_on_account][:total_content] = sums.sum(&:total_content)
      @_sums[day_on_account][:total_price]   = sums.sum(&:total_price)
    end
  end

  def deliveries_by(day:, on_account: nil)
    @_deliveries[[day, on_account]] || []
  end

  def sums_by(day: nil, on_account: nil)
    @_sums[[day, on_account].compact]
  end

  private

  def product_counts
    product_counts_report(         [:date, :on_account])
      .merge(product_counts_report([:date]))
      .merge(product_counts_report([:on_account]))
      .merge(product_counts_report([]))
  end

  def deliver_sums
    sums_report(         [:date, :on_account])
      .merge(sums_report([:date]))
      .merge(sums_report([:on_account]))
      .merge sums_report([])
  end

  def base_filter
    { date: @start_date..@end_date, product_group: product_group }
  end

  def product_counts_report(groups)
    groups << :product_number
    DeliveryReport.new(
      filter: base_filter.merge(has_content: true),
      groups: groups,
      sums:   [:counts]
    ).rows.group_by { |del| (groups - [:product_number]).map { |group| del.send(group) } }
  end

  def sums_report(groups)
    DeliveryReport.new(
      filter: base_filter,
      groups: groups,
      sums:   [:total_content, :total_price]
    ).rows.group_by { |del| groups.map { |group| del.send(group) } }
  end
end
