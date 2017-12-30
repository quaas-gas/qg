class ReportDelivery

  attr_reader :delivery, :customer, :products, :total_content, :total_price, :cat_content

  delegate :date, :number, :on_account, to: :delivery

  def initialize(delivery, product_group)
    @delivery      = delivery
    @customer      = "#{@delivery.customer.name}, #{@delivery.customer.city}"
    @products      = {}
    @total_content = 0
    @total_price   = Money.new 0, 'EU4NET'
    @cat_content   = {}

    @delivery.items.where(product_group: product_group).find_each do |item|
      @products[item.product_number] = item.count
      @total_content += item.total_content
      @total_price   += item.total_price
      @cat_content[item.product_category] ||= 0
      @cat_content[item.product_category] += item.total_content
    end
  end
end
