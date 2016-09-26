$(document).on 'ready page:load', ->
  $('table.table-clickable > tbody > tr').click (el) =>
    url = $(el.currentTarget).data().url
    Turbolinks.visit(url) if url?
  $('table.table-clickable > tbody > tr a').click (ev) => ev.stopPropagation()
