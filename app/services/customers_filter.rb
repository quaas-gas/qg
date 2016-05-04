class CustomersFilter
  attr_reader :params, :scope, :own_customer, :city, :kind

  def initialize(params, scope = Customer)
    @params       = params
    @scope        = scope
    @own_customer = { 'yes' => true, 'no' => false }[params[:own_customer]]
    @city         = params[:city]
    @kind         = params[:kind]

    filter_own_customer
    filter_city
    filter_kind
  end

  def cities
    scope.group(:city).order(:city).count
  end

  def kinds
    scope.group(:kind).order(:kind).count
  end

  def result
    @scope.order(order_options)
  end

  private

  def filter_own_customer
    @scope = scope.where(own_customer: own_customer) if own_customer.in?([true, false])
  end

  def filter_city
    @scope = scope.where(city: city) if city.present?
  end

  def filter_kind
    @scope = scope.where(kind: kind) if kind.present?
  end

  def order_options
    return params[:sort] if params[:sort].in?(%w(city name))
    :name
  end
end
