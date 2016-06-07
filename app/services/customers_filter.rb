class CustomersFilter
  attr_reader :params, :scope, :contractor, :city, :kind, :archived

  def initialize(params, scope = Customer)
    yes_no_map  = { 'yes' => true, 'no' => false }
    @params     = params
    @scope      = scope
    @contractor = params[:contractor]
    @city       = params[:city]
    @kind       = params[:kind]
    @archived   = yes_no_map[params[:archived]]
    @archived ||= false

    filter_contractor
    filter_city
    filter_kind
    filter_archived
  end

  def contractors
    Setting.contractors
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

  def filter_contractor
    @scope = scope.where(contractor: contractor) if contractor.present?
  end

  def filter_city
    @scope = scope.where(city: city) if city.present?
  end

  def filter_kind
    @scope = scope.where(kind: kind) if kind.present?
  end

  def filter_archived
    @scope = scope.where(archived: archived)
  end

  def order_options
    return params[:sort] if params[:sort].in?(%w(city name))
    :name
  end
end
