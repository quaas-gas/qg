class window.DeliveryForm
  constructor: ->
    newForm = $('form.new_delivery')
    customerSelect = newForm.find('select[name="delivery[customer_id]"]')
    customerSelect.on 'change', ->
      window.location = '/deliveries/new?customer_id=' + customerSelect.val()
    if customerSelect.val() is ''
      customerSelect.select2('open')
    else
      $('tbody tr:first-child .delivery_items_count_back input').focus()

    $('input[name="delivery[on_account]"]').change -> @toggleHeader

    @renderSums()
    $('.delivery_items_count input, .delivery_items_unit_price input').change @renderSums
    $('.delivery_items_count_back input').change @setCount

    $('input[name="delivery[number]"]').change @checkNumber
    @checkNumber()

  toggleHeader: -> $('.page-header h2 > span').toggleClass('hidden')

  parsePriceInput: (val) -> val.replace(',', '.')
  parsePriceOutput: (val) -> val.toFixed(4).toString().replace('.', ',')

  renderSums: =>
    sum = 0
    $('table tbody tr').each (index, tr) =>
      tr = $(tr)
      count = tr.find('.delivery_items_count input').val()
      unitPrice = @parsePriceInput tr.find('.delivery_items_unit_price input').val()
      total = count * unitPrice
      tr.find('p.total-price').text @parsePriceOutput(total)
      sum += total

    $('table tfoot .total-price').text @parsePriceOutput(sum)

  setCount: (event) =>
    countBackInput = $(event.currentTarget)
    countInput = countBackInput.parents('tr').find('.delivery_items_count input')
    countInput.val(countBackInput.val()) if countInput.val() is ''

  checkNumber: =>
    number = $('input[name="delivery[number]"]').val()
    if number isnt ''
      $.getJSON '/deliveries.json?number=' + number, {}, (deliveries) =>
        warningBox = $('.existing-deliveries-list')
        if deliveries.length > 0
          for delivery in deliveries
            date = new Date(delivery.date)
            date = date.toLocaleDateString('de-DE', {day: '2-digit', month: '2-digit', year: 'numeric'})
            url = delivery.url.replace '.json', ''
            link = $("<a href='#{url}'>").append "#{date} #{delivery.customer}"
            li = $('<li>').append link
            warningBox.find('ul').append li
          warningBox.removeClass 'hidden'
        else
          warningBox.addClass 'hidden'

