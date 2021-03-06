class window.DeliveryForm
  constructor: ->
    newForm = $('form.new_delivery')
    customerSelect = newForm.find('select[name="delivery[customer_id]"]')
    customerSelect.off('change').change ->
      Turbolinks.visit '/deliveries/new?customer_id=' + customerSelect.val()
    if customerSelect.val() is ''
      customerSelect.select2('open')
    else
      #$('tbody tr:first-child .delivery_items_count_back input').focus()
      $('.delivery_number input').focus()

    $('input:checkbox[name="delivery[on_account]"]').off('change').change @toggleHeader

    @renderSums()
    $('.delivery_items_count input, .delivery_items_unit_price input').off('change').change @renderSums
    $('.delivery_items_unit_price input').off('change').change @renderTaxUnitPrice
    $('.delivery_items_count_back input').off('change').change @setCount
    $('p.unit-price-tax a').off('click').click @unitPriceTaxClicked

    $('input[name="delivery[number]"]').change @checkNumber
    @checkNumber() if newForm.length > 0 # not on edit form

    @customerPriceUrl = $('.data').data('customerPriceUrl')

    $('.delivery_items_product select').off('change').change @productChanged

    $('a.add-item').off('click').click @showNewItem

  toggleHeader: -> $('.page-header h2 > span').toggleClass('hidden')

  parsePriceInput: (val) -> val.replace(',', '.')
  parsePriceOutput: (val, number = 2) -> val.toFixed(number).toString().replace('.', ',')

  renderSums: =>
    sum = 0
    $('table.items-table tbody tr').each (index, tr) =>
      tr = $(tr)
      count = tr.find('.delivery_items_count input').val()
      unitPrice = @parsePriceInput tr.find('.delivery_items_unit_price input').val()
      total = count * unitPrice
      tr.find('p.total-price-net').text @parsePriceOutput(total)
      tr.find('p.total-price').text @parsePriceOutput(total * 1.19)
      sum += total

    $('table tfoot .total-price-net').text @parsePriceOutput(sum)
    $('table tfoot .total-price').text @parsePriceOutput(sum * 1.19)

  renderTaxUnitPrice: (event) =>
    input = $(event.target)
    val = @parsePriceInput input.val()
    input.parents('tr').find('p.unit-price-tax a').text @parsePriceOutput(val * 1.19)

  setCount: (event) =>
    countBackInput = $(event.currentTarget)
    countInput = countBackInput.parents('tr').find('.delivery_items_count input')
    countInput.val(countBackInput.val()) if countInput.val() is ''
    @renderSums()

  checkNumber: =>
    number = $('input[name="delivery[number]"]').val()
    if number isnt ''
      $.getJSON '/deliveries.json?number=' + number, {}, (deliveries) =>
        inputWrapper = $('.delivery_number')
        inputWrapper.find('span.help-block').remove()
        if deliveries.length > 0
          span = $("<span class='help-block'>LSN schon vergeben: </span>")
          ul = $('<ul class="list-inline">')
          for delivery in deliveries
            date = new Date(delivery.date)
            date = date.toLocaleDateString('de-DE', {day: '2-digit', month: '2-digit', year: 'numeric'})
            url = delivery.url.replace '.json', ''
            link = $("<a href='#{url}'>").append "#{date} #{delivery.customer}"
            li = $('<li>').append link
            ul.append li
          span.append ul
          inputWrapper.addClass('has-warning').append span
        else
          inputWrapper.removeClass('has-warning')

  productChanged: (event) =>
    input = $(event.target)
    product_id = input.val()
    tr = input.parents('tr')
    $.getJSON @customerPriceUrl + '?product_id=' + product_id, {}, (price) =>
      tr.find('.delivery_items_name input').val price.name
      tr.find('.delivery_items_unit_price input').val(price.price).change()

  showNewItem: (event) =>
    $('table.items-table tbody tr.hidden').first().removeClass('hidden')

  unitPriceTaxClicked: (event) =>
    event.preventDefault()
    link = $(event.target)
    td = link.parents('td')
    td.find('p.unit-price-tax').hide()
    td.append $("""<div class="form-group"><input tabindex="-1" class="form-control" type="text" value="#{link.text()}" ></div>""")
    input = td.find('input')
    input.focus()
    input.focusout @unitPriceTaxChanged

  unitPriceTaxChanged: (event) =>
    inputTax = $(event.target)
    td = inputTax.parents('td')
    inputNet = td.parents('tr').find('.delivery_items_unit_price input')
    taxVal = @parsePriceInput inputTax.val()
    inputNet.val @parsePriceOutput(taxVal / 1.19, 4)
    inputNet.change()
    td.find('p.unit-price-tax').show()
    td.find('div.form-group').remove()
