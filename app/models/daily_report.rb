class DailyReport

  attr_reader :day, :product_group, :content_categories

  def initialize(day, product_group, **options)
    @day                = day
    @product_group      = product_group
    @content_categories = options[:content_categories] || []
  end

  def deliveries
    Delivery
      .where(id: delivery_items_scope.select(:delivery_id))
      .joins(:customer).includes(:customer, :items)
      .order(:on_account, :number).map { |del| ReportDelivery.new del }
  end

  def count_sums(on_account: nil)
    delivery_items(on_account: on_account).group(:product_number).sum(:count)
  end

  def content_sums(on_account: nil)
    delivery_items(on_account: on_account).where(product_category: content_categories).group(:product_category)
      .sum('total_content_in_g / 1000')
  end

  def total_price(on_account: nil)
    price = delivery_items(on_account: on_account).sum(:total_price_cents)
    Money.new(price, 'EU4NET')
  end

  private

  def delivery_items(on_account: nil)
    on_account.nil? ? delivery_items_scope : delivery_items_scope.where('deliveries.on_account' => on_account)
  end

  def delivery_items_scope
    DeliveryItem.where(product_group: product_group).joins(:delivery).where('deliveries.date' => day)
  end
end