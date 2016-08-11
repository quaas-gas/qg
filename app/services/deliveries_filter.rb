class DeliveriesFilter
  attr_reader :params, :scope, :number, :date, :on_account, :seller

  def initialize(params, scope = Delivery)
    yes_no_map  = { 'yes' => true, 'no' => false }
    @params     = params
    @scope      = scope
    @number     = params[:number]
    @date       = params[:date]
    @seller     = params[:seller]
    @on_account = yes_no_map[params[:on_account]]

    filter_number
    filter_date
    filter_seller
    filter_on_account
  end

  def dates
    Delivery.group(:date).order(date: :desc).count
  end

  def sellers
    Delivery.where(date: date).group(:seller).count
  end

  def result
    @scope.order(order_options)
  end

  private

  def filter_number
    @scope = scope.where(number: number) if number.present?
  end

  def filter_date
    @scope = scope.where(date: date) if date.present?
  end
  def filter_seller
    filter_val = seller == 'none' ? nil : seller
    @scope = scope.where(seller_id: filter_val) if seller.present?
  end

  def filter_on_account
    @scope = scope.where(on_account: on_account) if on_account.in?([true, false])
  end

  def order_options
    # return params[:sort] if params[:sort].in?(%w(city name))
    { number: :desc }
  end
end
