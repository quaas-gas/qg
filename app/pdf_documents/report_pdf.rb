require 'prawn/measurement_extensions'

class ReportPdf < ApplicationDocument

  attr_reader :report, :company

  def initialize(report)
    @debug = false
    @margin_top = 28.mm
    @margin_bottom = 15.mm
    @margin_side = 10.mm
    super(page_size: 'A4', page_layout: :landscape, margin: [@margin_top, @margin_side, @margin_bottom])
    @report = report
    @company = Company.current
    generate
  end

  def filename
    "#{@report.name}.pdf"
  end

  def generate
    stroke_bounds if @debug
    write_header
    move_down 10
    write_report
    write_total_sums
    number_pages 'Seite <page> von <total>', at: [bounds.right - 150, 0], width: 150, align: :right, size: 10
    # write_footer
  end

  def write_header
    repeat(:all) do
      height = @margin_top / 2
      bounding_box [0, bounds.top + height], width: bounds.right, height: height do

        text @report.name, size: 16
        text "#{ldate @report.start_date} - #{ldate @report.end_date}", size: 12, style: :italic
        # stroke_bounds if @debug
      end
    end
  end

  def title_text
    "#{@report.name} vom #{ldate @report.start_date} bis #{ldate @report.end_date}"
  end

  def write_report
    @report.days.each do |day|
      text ldate(day, format: '%a %d.%m.%Y'), size: 10, style: :bold

      rows = deliveries_array_by day

      sum_rows = 1
      sum_rows += 1 if @report.sums_by(day: day, on_account: false)
      sum_rows += 1 if @report.sums_by(day: day, on_account: true)
      font_size 9 do
        table rows, deliveries_table_options do |t|
          t.row(0).style background_color: 'dddddd'
          t.row(0).font_style = :bold
          1.upto(sum_rows).each do |row_number|
            t.row(row_number * -1).style background_color: 'dddddd'
            t.row(row_number * -1).font_style = :bold
          end
          t.cells.style { |c| c.align = :right if c.column > 1 }
        end
      end
      move_down 10
    end
  end

  def deliveries_table_header
    header = %w(LSN Kunde)
    @report.products.each { |product| header << product.number }
    header += ['kg ges', 'Netto', 'Brutto', 'R']
    header
  end

  def deliveries_array_by(day)
    res = [deliveries_table_header]
    [false, true].each do |on_account|
      deliveries = @report.deliveries_by(day: day, on_account: on_account)
      res += deliveries.map do |delivery|
        products = delivery.products
        [delivery.number, delivery.customer.to_s[0..35]] +
          @report.products.map { |product| products[product.number] } +
          [ delivery.total_content,
            nontax_price(delivery.total_price),
            tax_price(delivery.total_price),
            (delivery.on_account ? 'R' : '')
          ]
      end
    end
    [false, true, nil].each do |on_account|
      sums = @report.sums_by(day: day, on_account: on_account)
      label = on_account ? 'Rechnung' : 'Bar'
      label = ldate(day, format: '%d.%m.') if on_account.nil?
      if sums
        res << sum_row(sums, title: label)
      end
    end
    res
  end

  def delivery_array(delivery, on_account)
    del = [delivery[:number], delivery[:customer]]
    @report.products.each do |product|
      del << delivery[:products][product].to_s
    end
    del << delivery[:other_products].map { |i| "#{i[:count]} x #{i[:name] }" }.join("\n")
    @report.content_product_categories.each do |category|
      del << (delivery[:content][category] ? delivery[:content][category].round(0) : '')
    end
    del << delivery[:content][:total].round(0)
    del << nontax_price(delivery[:total_price])
    del << tax_price(delivery[:total_price])
    del << (on_account ? 'R' : '')
    del
  end

  def deliveries_table_options
    {
      row_colors:    %w(EEEEEE FFFFFF),
      header:        true,
      width:         bounds.right,
      column_widths: { 0 => 45, 1 => 180 },
      cell_style:    { border_width: 0, padding: [1, 1] }
    }
  end

  def sum_row(sums, title: '')
    res = [title, '']
    products = sums[:products]
    @report.products.each { |product| res << products[product.number] }
    # res << ''
    # @report.content_product_categories.each { |category| res << sums[:content][category] }
    res << sums[:total_content]
    res << nontax_price(sums[:total_price])
    res << tax_price(sums[:total_price])
    res << ''
    res
  end

  def write_total_sums
    move_down 15

    font_size 10 do
      table sums_array, sums_table_options do |t|
        t.cells.style { |c| c.align = :right if c.column > 1 }
      end
    end
  end

  def sums_array
    [
      sums_table_header,
      sum_row(@report.sums_by(on_account: false), title: 'Bar'),
      sum_row(@report.sums_by(on_account: true),  title: 'Rechnung'),
      sum_row(@report.sums_by,                    title: 'Gesamt'),
    ]
  end

  def sums_table_options
    {
      row_colors:    %w(dddddd),
      width:         bounds.right,
      column_widths: { 0 => 230, 1 => 10 },
      cell_style:    { border_width: 0, padding: [2, 3], font_style: :bold }
    }
  end

  def sums_table_header
    header = ['', '']
    @report.products.each { |product| header << product.number }
    header += ['kg ges', 'Netto', 'Brutto', '']
    header
  end

  def write_footer
    # repeat(:all) do
    #   font font.name, size: 9, style: :italic
    #   box_width = bounds.right / 3
    #   small_box_options = { width: box_width - 10, height: @margin_bottom }
    #   wide_box_options = { width: box_width + 5, height: @margin_bottom }
    #   box1_position = 0
    #   box2_position = box1_position + small_box_options[:width]
    #   box3_position = box2_position + wide_box_options[:width]
    #
    #   bounding_box([box1_position, 0], small_box_options) { text company.contact_lines }
    #   bounding_box([box2_position, 0], wide_box_options)  { text company.legal_info_lines }
    #   bounding_box([box3_position, 0], wide_box_options)  { text company.bank_info_lines }
    # end
  end

end
