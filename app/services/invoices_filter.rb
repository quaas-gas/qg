class InvoicesFilter
  attr_reader :params, :scope, :month, :year

  def initialize(params, scope = Invoice)
    @params = params
    @scope  = scope
    @month  = (params[:month] || Date.current.month).to_i
    @year   = (params[:year] || Date.current.year).to_i

    filter_year
    filter_month
  end

  def months
    counts = Invoice.group('extract(month from date)').where('extract(year from date) = ?', year).count
    counts.keys.each { |month| counts[month.to_i] = counts[month] }
    I18n.t('date.month_names').map.with_index do |month, index|
      [index, (index == 0) ? 'Monate' : "#{month} (#{counts[index] || 0})"]
    end.to_h
  end

  def years
    sql = 'SELECT DISTINCT extract(year from date) AS year FROM "invoices" order by year DESC'
    Invoice.connection.execute(sql).to_a.map { |year| year['year'].to_i }
  end

  def result
    @scope.order(order_options)
  end

  private

  def filter_month
    @scope = scope.where('extract(month from date) = ?', month) unless month == 0
  end

  def filter_year
    @scope = scope.where('extract(year from date) = ?', year)
  end

  def order_options
    { number: :desc }
  end
end
