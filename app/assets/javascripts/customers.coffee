class window.Customer
  constructor: (@id) ->

  url:     -> "/customers/#{@id}.json"
  fetch: (callback) ->
    @callback = callback
    jQuery.getJSON @url(), @success
  success: (data) =>
    this[key] = val for key, val of data
    @callback()

  render: (selector) =>
    elem = $(selector)
    info = $('<div>')
    p = $('<p>')
    p.append "<a href='#{@link}' target='_blank'>#{@name}, #{@city}</a>"
    p.append "<br>"
    p.append if @gets_invoice then 'Rechnungskunde' else 'Barzahler'
    p.append "<br>"
    p.append if @tax then 'Bruttopreise' else 'Nettopreise'
    info.append p
    table = $('<table class="table table-condensed table-striped">')
    for price in @prices.sort((a,b) -> a.product > b.product)
      table.append $('<tr>').append("<th>#{price.product}</th><td class='price'>#{price.price}</td>")
    info.append table
    elem.html info
