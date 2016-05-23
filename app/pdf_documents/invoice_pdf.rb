class InvoicePdf < ApplicationDocument

  attr_reader :invoice

  def initialize(invoice)
    super(margin: 80)
    @invoice = invoice
    generate
  end

  def filename
    "#{Invoice.model_name.human}_#{invoice.number.sub('/', '-')}.pdf"
  end

  def generate
    # stroke_axis
    # text "the cursor is here: #{cursor}"
    # text "now it is here: #{cursor}"
    # move_down 200
    # text "on the first move the cursor went down to: #{cursor}"
    # move_up 100
    # text "on the second move the cursor went up to: #{cursor}"
    # move_cursor_to 50
    # text "on the last move the cursor went directly to: #{cursor}"

    write_header
    write_address
    write_right_box
    write_heading
    write_pre_message
    write_deliveries
    write_positions
    write_post_message
    write_footer
  end

  def write_header
    move_down 60
    stroke_horizontal_rule
    move_down 10
  end

  def write_address
    bounding_box([0, cursor], width: 200, height: 100) do
      text invoice.address
    end
  end

  def write_right_box
    bounding_box([300, cursor + 100], width: 140, height: 100) do
      # text "Kunden-Nr.: #{invoice.customer_id}"
      # text "Datum: #{ldate(invoice.date)}"

      colum_widths           = [70, 70]
      options                = {
        width: colum_widths.sum,
        column_widths: colum_widths,
        cell_style: { border_width: 0 }
      }
      data = [['Kunden-Nr.', invoice.customer_id.to_s], ['Datum', ldate(invoice.date)]]
      table data, options do |t|
        # t.cells.style { |c| c.align = :right if c.column == 1 }
      end
    end
    move_down 50
  end

  def write_heading
    text "#{Invoice.model_name.human} Nr. #{invoice.number}", size: 20
    move_down 20
  end

  def write_pre_message
    text invoice.pre_message
  end

  def write_deliveries
    # table delivery_array, cell_style: { border_width: 0 } do
    #   # row(0).font_style = :bold
    #   # self.header = true
    #   # self.row_colors = %w(EEEEEE FFFFFF)
    #   # self.column_widths = [40, 300]
    # end
    invoice.deliveries.each do |delivery|
      text "#{delivery.number}: #{ldate(delivery.date)}", style: :italic, size: 11
    end
    move_down 10
  end

  def delivery_array
    # [%w(Lieferschein Datum)] +
      invoice.deliveries.map { |delivery| [delivery.number, ldate(delivery.date)] }
  end

  def write_positions
    stroke_horizontal_rule
    colum_widths = [50, 220, 90, 90]
    options = {
      width: colum_widths.sum,
      column_widths: colum_widths,
      cell_style: { border_width: 0 }
    }
    table positions_array, options do
      self.header = true
      self.row_colors = %w(EEEEEE FFFFFF)
      # self.column_widths = [40, 300]
      cells.style { |c| c.align = :right if c.column > 1 }
    end
    stroke_horizontal_rule
    colum_widths = [360, 90]
    options = {
      width: colum_widths.sum,
      column_widths: colum_widths,
      cell_style: { border_width: 0 }
    }
    table sum_rows, options do |t|
      bold_line = invoice.tax ? 0 : 2
      t.row(bold_line).font_style = :bold
      t.cells.style { |c| c.align = :right }
    end
    stroke_horizontal_rule
    move_down 20
  end

  def positions_array
    [%w(Menge Bezeichnung Einzelpreis Gesamtpreis)] +
      invoice.items.map do |item|
        [item.count.to_s, item.name, display_price(item.unit_price), display_price(item.total_price)]
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

  def sum_name
    invoice.tax ? 'Rechnungsendbetrag' : 'Nettobetrag'
  end

  def write_post_message
    text invoice.post_message
  end

  def write_footer

  end


end
