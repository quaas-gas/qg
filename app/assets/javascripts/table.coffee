#$ ->
#  $('table.table-clickable > tbody > tr').click (el) =>
#    url = $(el.currentTarget).data().url
#    Turbolinks.visit(url) if url?
#  $('table.table-clickable > tbody > tr a').click (ev) => ev.stopPropagation()

$ ->
  $('table.table-clickable > tbody > tr').click (el) =>
    if $(el.target).is('td')
      url = $(el.currentTarget).data().url
      Turbolinks.visit(url) if url?
