class window.StatisticForm
  constructor: ->
    newForm = $('form.new_statistic')
#    timeRangeSelect = newForm.find('select[name="statistic[time_range]"]')
#    groupingXSelect = newForm.find('select[name="statistic[grouping_x]"]')
#    groupingYSelect = newForm.find('select[name="statistic[grouping_y]"]')
#    filterRegionsSelect = newForm.find('select[name="statistic[filter_regions][]"]')
    newForm.find('select').change @inputChanged

  inputChanged: (event) =>
#    @collectData()
    jQuery.ajax({
      url: "test.html",
      context: this
    }).done ->
      this

  parsePriceOutput: (val) -> val.toFixed(2).toString().replace('.', ',')

  renderResult: (result) ->

