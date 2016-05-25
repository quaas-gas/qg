class InvoicePdf < ApplicationDocument

  attr_reader :invoice, :company

  def initialize(invoice)
    super(margin: [80, 60, 60])
    @invoice = invoice
    @company = Company.current
    @header_text_options = { size: 30, style: :italic, align: :center }
    generate
  end

  def filename
    "#{Invoice.model_name.human}_#{invoice.number.sub('/', '-')}.pdf"
  end

  def generate
    write_header
    move_down 60
    write_address
    write_right_box
    move_down 25
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
  end

  def write_header
    repeat(:all) do
      bounding_box [0, bounds.top + 30], width: bounds.right, height: 40 do
        text company.name, @header_text_options
      end
    end
  end

  def write_address
    bounding_box([0, cursor], width: 250, height: 100) do
      text company.full_address.join(' • '), size: 8, style: :italic
      stroke_horizontal_rule
      move_down 10
      text invoice.address
    end
  end

  def write_right_box
    y = cursor + 50
    box1_width = 100
    box2_width = 70
    x = bounds.right - (box1_width + box2_width)
    bounding_box([x, y], width: box1_width, height: 100) do
      text I18n.t(:customer_number) + ':'
      text I18n.t(:invoice_date) + ':'
    end

    x += box1_width
    bounding_box([x, y], width: box2_width, height: 100) do
      text invoice.customer_id.to_s
      text ldate(invoice.date)
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
    table positions_array, positions_table_options do |t|
      t.cells.style { |c| c.align = :right unless c.column == 1 }
    end
  end

  def positions_array
    [%w(Menge Bezeichnung Einzelpreis Gesamtpreis)] +
      invoice.items.map do |item|
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
    table sum_rows, positions_sum_options do |t|
      t.row(invoice.tax ? 0 : 2).font_style = :bold
      t.cells.style { |c| c.align = :right }
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

  def write_footer
    repeat(:all) do
      footer_height = 65
      box_width = bounds.right / 3
      text_options = { size: 9, style: :italic }
      bounding_box([0, 20], width: bounds.right, height: footer_height) do
        # stroke_horizontal_rule
        bounding_box [0, footer_height], width: box_width - 30, height: footer_height do
          text company.contact_lines, text_options
        end
        bounding_box [box_width - 30, footer_height], width: box_width + 15, height: footer_height do
          text company.legal_info_lines, text_options
        end
        bounding_box [box_width * 2 - 15, footer_height], width: box_width + 15, height: footer_height do
          text company.bank_info_lines, text_options
        end
      end
    end
  end

end
