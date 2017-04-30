class DeliveryReport
  FILTERS = {
    product_group: 'delivery_items.product_group',
    region:        'customers.region',
    has_content:   'delivery_items.has_content',
    date:          'deliveries.date'
  }
  GROUPS = {
    date:              'deliveries.date',
    region:            'customers.region',
    customer_category: 'customers.category',
    customer_name:     'customers.name',
    on_account:        'deliveries.on_account',
    delivery_number:   'deliveries.number',
    has_content:       'delivery_items.has_content',
    product_group:     'delivery_items.product_group',
    product_category:  'delivery_items.product_category',
    product_number:    'delivery_items.product_number',
  }
  SUMS = {
    counts:        'sum(count)',
    total_price:   'sum(total_price_cents)',
    total_content: 'sum(total_content_in_g)'
  }

  attr_reader :filter, :groups, :sums, :fields

  def initialize(filter: {}, groups: GROUPS.keys, sums: SUMS.keys)
    @filter = filter.symbolize_keys.slice *FILTERS.keys
    @groups = groups.map(&:to_sym) & GROUPS.keys
    @sums   = sums.map(&:to_sym) & SUMS.keys
    @fields = @groups + @sums
  end

  def result
    @result ||= ActiveRecord::Base.connection.execute sql
  end

  def rows
    result.map { |row| Row.new row }
  end

  def count
    result.ntuples
  end

  def self.filters
    FILTERS.keys
  end

  def self.groups
    GROUPS.keys
  end

  def self.sums
    SUMS.keys
  end

  def self.fields
    groups + sums
  end

  private

  def mapped_filter
    res = {}
    filter.each { |key, value| res[FILTERS[key]] = value }
    res
  end

  def sql
    _groups = groups.map { |g| GROUPS[g] }
    DeliveryItem.joins(delivery: :customer)
      .where(mapped_filter)
      .order(_groups)
      .group(_groups)
      .select(mapping(groups, GROUPS) + mapping(sums, SUMS))
      .to_sql
  end

  def mapping(selected, dict)
    selected.map { |field| "#{dict[field]} as #{field}" }
  end

  class Row
    FIELDS = DeliveryReport.fields
    SUMS = DeliveryReport.sums
    attr_reader *FIELDS

    def initialize(hash)
      @attributes = hash.symbolize_keys.slice *FIELDS
      SUMS.each { |sum| @attributes[sum] = @attributes[sum].to_i if @attributes.has_key? sum }
      @attributes[:date] = Date.parse(@attributes[:date]) if @attributes.has_key? :date
      @attributes[:on_account] = @attributes[:on_account] == 't' if @attributes.has_key? :on_account
      @attributes.each { |attr, value| instance_variable_set "@#{attr}", value }
    end

    def [](key)
      @attributes[key]
    end

    def total_content
      @attributes[:total_content].to_i / 1000
    end

    def total_price
      Money.new(@attributes[:total_price], 'EU4NET')
    end
  end
end
