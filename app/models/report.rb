class Report < ActiveRecord::Base

  validates :name, presence: true

  attr_reader :grouped_deliveries

  scope :in_menu, -> { where in_menu: true }

  def deliveries
    products     = Product.where category: product_categories
    delivery_ids = DeliveryItem.select(:delivery_id).where(product: products)
    Delivery.where(id: delivery_ids)
  end

  def deliveries_between(start_date, end_date)
    deliveries.where('date >= ? AND date <= ?', start_date, end_date)
  end

  # def deliveries_at(day)
  #   @grouped_deliveries[day.to_date]
  # end

  # {
  #   '1.1.' => {
  #     on_account: {
  #       true => {
  #         deliveries: [
  #           {
  #             id: 1,
  #             number: '',
  #             customer: '',
  #             products: { 'bg05' => 1, 'bg11' => 3 },
  #             content: { 'Brenngas' => 38, total: 38 },
  #             total_price: Money.new(33.67)
  #           }
  #                     ],
  #         products: { bg05: 7 },
  #         content: { 'Brenngas' => 102, total: 102 }
  #       },
  #       false => {
  #         deliveries: [],
  #         products: { bg05: 5 },
  #         content: { 'Brenngas' => 17 }
  #       }
  #     },
  #     products: { bg05: 12 },
  #     content: { 'Brenngas' => 30, total: 102 }
  #   }
  # }

  def calculate!(start_date, end_date)
    @grouped_deliveries = {}
    dates_hash = @grouped_deliveries[:dates] = {}

    grouped_dels = deliveries_between(start_date, end_date)
      .order(:date, :on_account, :number)
      .includes(:customer, items: :product)
      .all
      .group_by(&:date)
    grouped_dels.each do |date, deliveries|
      date_hash = dates_hash[date] = { on_account: {}}

      deliveries.group_by(&:on_account).each do |on_account, deliveries|
        on_account_hash = { deliveries: deliveries.map { |del| delivery_hash_for(del) } }
        date_hash[:on_account][on_account] = on_account_hash
        calculate_sums on_account_hash, on_account_hash[:deliveries]
      end
      calculate_sums date_hash, date_hash[:on_account].values
    end
    calculate_sums @grouped_deliveries, dates_hash.values
  end

  def delivery_hash_for(delivery)
    total_price    = Money.new(0)
    products_hash  = {}
    other_products = []
    content_hash   = {}

    delivery.items.each do |item|
      category = item.product&.category
      next unless category.in?(product_categories)
      number = item.product&.number
      if number.in?(products)
        products_hash[number] = (products_hash[number] || 0) + item.count
      else
        other_products << { count: item.count, name: (number || item.name) }
      end
      if category.in?(content_product_categories)
        content_hash[category] = (content_hash[category] || 0) + item.total_content
      end
      total_price += item.total_price
    end
    content_hash[:total] = content_hash.values.sum

    {
      id:             delivery.id,
      number:         delivery.number,
      customer:       delivery.customer.name,
      tax:            delivery.tax,
      total_price:    total_price,
      products:       products_hash,
      other_products: other_products,
      content:        content_hash
    }
  end

  def calculate_sums(hash, listing)
    hash[:products] = products.each_with_object({}) do |product, hash|
      hash[product] = listing.map { |item| item[:products][product].to_i }.sum
    end
    hash[:content] = content_product_categories.each_with_object({}) do |cat, hash|
      hash[cat] = listing.map { |del| del[:content][cat].to_i }.sum
    end
    hash[:content][:total] = hash[:content].values.sum
    hash[:total_price] = listing.map { |item| item[:total_price] || Money.new(0) }.sum
    hash
  end

  def on_account_sums(on_account)
    listing = @grouped_deliveries[:dates].values.flat_map do |date_hash|
      on_accounts = date_hash[:on_account][on_account]
      on_accounts ? on_accounts[:deliveries] : []
    end
    calculate_sums({}, listing)
  end
end
