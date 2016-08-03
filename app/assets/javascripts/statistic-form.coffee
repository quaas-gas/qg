class window.StatisticForm
  constructor: ->
    $('select, input.date').change @inputChanged
    @inputChanged()
    $('select[name="statistic[time_range_relative]"]').change @toggleDateFields
    @toggleDateFields()
  inputChanged: (event) =>
    jQuery.ajax(
      url: '/statistics/preview',
      data: @collectData()
    ).done (data) -> $('.preview').html data

  collectData: ->
    statistic:
      time_range_relative: @getSelect('time_range_relative')
      start_date:          @getDate('start_date')
      end_date:            @getDate('end_date')
      grouping_x:          @getSelect('grouping_x')
      grouping_y:          @getSelect('grouping_y')
      regions:             @getMultiSelect('regions')
      customer_categories: @getMultiSelect('customer_categories')
      product_categories:  @getMultiSelect('product_categories')
      sums_of:             @getSelect('sums_of')

  getSelect: (name)      -> $('select[name="statistic[' + name + ']"]').val()
  getMultiSelect: (name) -> $('select[name="statistic[' + name + '][]"]').val() || ['']
  getDate: (name)        -> $('input[name="statistic[' + name + ']"]').val()

  toggleDateFields: =>
    timeRange = $('select[name="statistic[time_range_relative]"]').val()
    $('input.date').attr('disabled', (timeRange isnt 'custom'))
