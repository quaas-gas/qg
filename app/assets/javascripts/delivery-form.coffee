class window.DeliveryForm
  constructor: ->

    newForm = $('form.new_delivery')
    customerSelect = newForm.find('select[name="delivery[customer_id]"]')
    customerSelect.on 'change', ->
      window.location = '/deliveries/new?customer_id=' + customerSelect.val()
    if customerSelect.val() is ''
      customerSelect.select2('open')
    else
      newForm.find('input[name="delivery[number]"]').focus()

    $('input[name="delivery[on_account]"]').change -> @toggleHeader

    @renderSums()
    $('.delivery_delivery_items_count input, .delivery_delivery_items_unit_price input').change @renderSums

  toggleHeader: -> $('.page-header h2 > span').toggleClass('hidden')

  parsePriceInput: (val) -> val.replace(',', '.')
  parsePriceOutput: (val) -> val.toFixed(4).toString().replace('.', ',')

  renderSums: =>
    sum = 0
    $('table tbody tr').each (index, tr) =>
      tr = $(tr)
      count = tr.find('.delivery_delivery_items_count input').val()
      unitPrice = @parsePriceInput tr.find('.delivery_delivery_items_unit_price input').val()
      total = count * unitPrice
      tr.find('p.total-price').text @parsePriceOutput(total)
      sum += total

    $('table tfoot .total-price').text @parsePriceOutput(sum)
