class CustomersFilter
  attr_reader :params, :scope, :city, :category, :archived

  def initialize(params, scope = Customer)
    yes_no_map  = { 'yes' => true, 'no' => false }
    @params     = params
    @scope      = scope
    @city       = params[:city]
    @category   = params[:category]
    @archived   = yes_no_map[params[:archived]]
    @archived ||= false

    filter_city
    filter_category
    filter_archived
  end

  def cities
    scope.group(:city).order(:city).count
  end

  def categories
    scope.group(:category).order(:category).count
  end

  def result
    @scope.order(order_options)
  end

  private

  def filter_city
    @scope = scope.where(city: city) if city.present?
  end

  def filter_category
    @scope = scope.where(category: category) if category.present?
  end

  def filter_archived
    @scope = scope.where(archived: archived)
  end

  def order_options
    return params[:sort] if params[:sort].in?(%w(city name))
    :name
  end
end
