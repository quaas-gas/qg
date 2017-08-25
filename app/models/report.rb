class Report < ActiveRecord::Base

  validates :name, :product_group, presence: true

  attr_accessor :start_date, :end_date

  scope(:in_menu, -> { where in_menu: true })

  def products
    @products ||= Product.where(group: product_group, in_stock: true).order(:number).all
  end

  def days
    ensure_date_range
    Delivery.joins(:items).uniq.order(:date)
      .where('delivery_items.product_group' => product_group, date: @start_date..@end_date).pluck(:date)
  end

  def daily_reports
    days.map { |day| DailyReport.new day, product_group, content_categories: content_product_categories }
  end

  def sum_report
    ensure_date_range
    DailyReport.new @start_date..@end_date, product_group, content_categories: content_product_categories
  end

  private

  def ensure_date_range
    raise 'start and end date must be set before running this action' unless start_date.is_a?(Date) && end_date.is_a?(Date)
  end
end
