class window.StatisticForm
  constructor: ->
    $('select').change @inputChanged
    @inputChanged()

  inputChanged: (event) =>
    jQuery.ajax(
      url: '/statistics/preview',
      data: @collectData()
    ).done (data) -> $('.preview').html data

  collectData: ->
    statistic:
      time_range_relative: $('select[name="statistic[time_range_relative]"]').val()
      grouping_x: $('select[name="statistic[grouping_x]"]').val()
      grouping_y: $('select[name="statistic[grouping_y]"]').val()
      regions: $('select[name="statistic[regions][]"]').val() || ['']
      customer_categories: $('select[name="statistic[customer_categories][]"]').val() || ['']
      product_categories: $('select[name="statistic[product_categories][]"]').val() || ['']
      sums_of: $('select[name="statistic[sums_of]"]').val()


