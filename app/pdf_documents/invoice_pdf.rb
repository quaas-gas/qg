require 'prawn/measurement_extensions'

class InvoicePdf < ApplicationDocument

  attr_reader :invoice, :customer, :company

  def initialize(invoice)
    @debug = false
    @margin_top = 28.mm
    @margin_bottom = 28.mm
    @margin_side = 20.mm
    super(page_size: 'A4', margin: [@margin_top, @margin_side, @margin_bottom])
    @invoice = invoice
    @customer = invoice.customer
    @company = Company.current
    @header_text_options = { size: 30, style: :italic, align: :center }
    generate
  end

  def filename
    "#{Invoice.model_name.human}_#{invoice.number.sub('/', '-')}.pdf"
  end

  def generate
    stroke_bounds if @debug
    write_header
    stroke_horizontal_rule if @debug
    write_address
    write_right_box
    write_heading
    move_down 20
    text invoice.pre_message
    write_deliveries
    move_down 10
    stroke_horizontal_rule
    write_positions
    stroke_horizontal_rule
    write_positions_sum
    stroke_horizontal_rule
    move_down 20
    text invoice.post_message
    write_footer
    write_stock_overview if customer.has_stock
  end

  def write_header
    repeat(:all) do
      height = @margin_top / 2
      bounding_box [0, bounds.top + height], width: bounds.right, height: height do
        text company.name, @header_text_options
        # stroke_bounds if @debug
      end
    end
  end

  def write_address
    y = bounds.top - (50.mm - @margin_top)
    bounding_box([0, y], width: 85.mm, height: 45.mm) do
      text company.full_address.join(' • '), size: 8, style: :italic
      stroke_horizontal_rule
      move_down 10
      text invoice.address
      stroke_bounds if @debug
    end
  end

  def write_right_box
    font_size 10 do
      y      = bounds.top - (50.mm - @margin_top)
      height = 50.mm
      width  = 35.mm
      box_options = { width: width, height: height }

      x = bounds.right - ( 2 * width)
      bounding_box [x, y], box_options do
        %i(phone fax email).each { |attr| text I18n.t(attr) + ':' }
        move_down 20
        %i(customer_number invoice_date).each { |attr| text I18n.t(attr) + ':' }
        stroke_bounds if @debug
      end

      x += width
      bounding_box [x, y], box_options do
        text company.phone
        text company.fax
        text company.email
        move_down 20
        text customer.id.to_s
        text ldate(invoice.date)
        stroke_bounds if @debug
      end
    end
  end

  def write_heading
    text "#{Invoice.model_name.human} Nr. #{invoice.number}", size: 20
  end

  def write_deliveries
    devs = invoice.deliveries.map { |d| "#{ldate d.date} (#{d.number})" }.join(', ')
    text devs, style: :italic, size: 11
    # invoice.deliveries.each do |delivery|
    #   text "#{delivery.number}: #{ldate(delivery.date)}", style: :italic, size: 11
    # end
  end

  def write_positions
    font_size 11 do
      table positions_array, positions_table_options do |t|
        t.cells.style { |c| c.align = :right unless c.column == 1 }
      end
    end
  end

  def positions_array
    [%w(Menge Bezeichnung Einzelpreis Gesamtpreis)] +
      invoice.items.order(:position).map do |item|
        [item.count.to_s, item.name, display_price(item.unit_price), display_price(item.total_price)]
      end
  end

  def positions_table_options
    {
      row_colors:    %w(EEEEEE FFFFFF),
      header:        true,
      width:         bounds.right,
      column_widths: { 0 => 50, 2 => 90, 3 => 90 },
      cell_style:    { border_width: 0, padding: [4, 5] }
    }
  end

  def write_positions_sum
    font_size 11 do
      table sum_rows, positions_sum_options do |t|
        t.row(invoice.tax ? 0 : 2).font_style = :bold
        t.cells.style { |c| c.align = :right }
      end
    end
  end

  def sum_rows
    if invoice.tax
      total = invoice.total_price
      tax = total.exchange_to('EU4NET').exchange_to('TAX')
      [['Rechnungsendbetrag', display_price(total)],
       ['darin enthaltene MwSt', display_price(tax)]]
    else
      sum = invoice.total_price
      tax = sum.exchange_to('TAX')
      total = sum.exchange_to('EU4TAX').exchange_to('EURTAX')
      [['Nettobetrag', display_price(sum)],
       ['MwSt', display_price(tax)],
       ['Rechnungsendbetrag', display_price(total)]]
    end
  end

  def positions_sum_options
    {
      width: bounds.right,
      column_widths: { 1 => 90 },
      cell_style: { border_width: 0, padding: [2, 5] }
    }
  end

  ### Stock Overview ###############################################################################

  def write_stock_overview
    start_new_page layout: :landscape
    height = @margin_top / 2
    bounding_box [0, bounds.top + height], width: bounds.right, height: height do
      text company.name, @header_text_options
    end
    move_down 40
    text t(:stock_invoice, number: invoice.number, date: ldate(invoice.date)), size: 16
    text customer.name, size: 13
    move_down 20

    font_size 11 do
      table stock_array, stock_table_options do |t|
        t.row(0).font_style = :italic
        t.row(1).font_style = :bold
        t.row(-1).font_style = :bold
        t.cells.style { |c| c.align = :right unless c.column == 0 }
      end
    end
  end

  def stock_array
    [%w(Lieferschein Datum) + products_in_stock.map(&:number)] +
      stock_row('Anfangsbestand', (invoice.previous&.date || customer.initial_stock_date)) +
      stock_deliveries.map { |delivery| stock_delivery_row(delivery) } +
      stock_row('neuer Bestand', invoice.date)
  end

  def stock_deliveries
    invoice.deliveries.order(:date).includes(items: :product)
  end

  def stock_delivery_row(delivery)
    [delivery.number, ldate(delivery.date)] + products_in_stock.map { |product| stock_diff delivery, product }
  end

  def stock_diff(delivery, product)
    item = delivery.items.to_a.find { |i| i.product_id == product.id }
    item ? item.stock_diff.to_s : ''
  end

  def stock_row(label, date)
    stock = Stock.new customer, date
    [[label, ldate(date)] + products_in_stock.map { |product| stock[product.number] }]
  end

  def products_in_stock
    @products_in_stock ||= Product.where(id: customer.prices.in_stock.select(:product_id)).to_a
  end

  def stock_table_options
    {
      row_colors:    %w(EEEEEE FFFFFF),
      header:        true,
      width:         bounds.right,
      column_widths: { 0 => 100, 1 => 70 },
      cell_style:    { border_width: 0, padding: [4, 5] }
    }
  end

  def write_footer
    repeat(:all) do
      font font.name, size: 9, style: :italic
      box_width = bounds.right / 3
      small_box_options = { width: box_width - 10, height: @margin_bottom }
      wide_box_options = { width: box_width + 5, height: @margin_bottom }
      box1_position = 0
      box2_position = box1_position + small_box_options[:width]
      box3_position = box2_position + wide_box_options[:width]

      bounding_box([box1_position, 0], small_box_options) { text company.contact_lines }
      bounding_box([box2_position, 0], wide_box_options)  { text company.legal_info_lines }
      bounding_box([box3_position, 0], wide_box_options)  { text company.bank_info_lines }
    end
  end

end
