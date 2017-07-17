class ReportDelivery

  attr_reader :delivery, :customer, :products, :total_content, :total_price

  delegate :date, :number, :on_account, to: :delivery

  def initialize(delivery)
    @delivery      = delivery
    @customer      = "#{@delivery.customer.name}, #{@delivery.customer.city}"
    @products      = {}
    @total_content = 0
    @total_price   = Money.new 0, 'EU4NET'

    @delivery.items.each do |item|
      @products[item.product_number] = item.count
      @total_content += item.total_content
      @total_price   += item.total_price
    end
  end

  def self.get(product_group, start_date, end_date)
    pg_items = DeliveryItem.select(:delivery_id).where(product_group: product_group)
    Delivery
      .where(id: pg_items)
      .joins(:customer).includes(:customer, :items)
      .order(:date, :number)
      .where(date: start_date..end_date)
      .all
      .map { |delivery| new delivery }
  end

  def self.sums(product_group, start_date, end_date)
    rows = DeliveryReport.new(
      filter: {
        date:          start_date..end_date,
        product_group: product_group,
      },
      groups: [:date, :on_account],
      sums:   [:total_content, :total_price]
    ).rows

    res = {}
    rows.group_by(&:date).each do |day, sums|
      res[day] = {}
      sums.group_by(&:on_account).each do |on_account, sums|
        res[day][on_account] = sums
      end
    end
    res
  end
end
