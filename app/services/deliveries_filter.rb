class DeliveriesFilter
  attr_reader :params, :scope, :date, :year, :on_account

  def initialize(params, scope = Delivery)
    yes_no_map  = { 'yes' => true, 'no' => false }
    @params     = params
    @scope      = scope
    # @year       = params[:year] || Date.current.year.to_s
    # filter_year
    @date       = params[:date] ? Date.parse(params[:date]) : scope.order(date: :desc).first.date
    @on_account = yes_no_map[params[:on_account]]

    filter_date
    filter_on_account
  end

  def dates
    Delivery.group(:date).order(date: :desc).count
  end

  # def years
  #   Delivery.years
  # end

  def result
    @scope.order(order_options)
  end

  private

  def filter_date
    @scope = scope.where(date: date)
  end

  # def filter_year
  #   @scope = scope.where('extract(year from date) = ?', year)
  # end

  def filter_on_account
    @scope = scope.where(on_account: on_account) if on_account.in?([true, false])
  end

  def order_options
    # return params[:sort] if params[:sort].in?(%w(city name))
    { number: :desc }
  end
end
