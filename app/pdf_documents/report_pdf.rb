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
    @report.daily_reports.each do |daily_report|
      text ldate(daily_report.day, format: '%a %d.%m.%Y'), size: 10, style: :bold

      rows = deliveries_array_by daily_report

      sum_rows = 3
      # sum_rows += 1 if @report.sums_by(day: day, on_account: false)
      # sum_rows += 1 if @report.sums_by(day: day, on_account: true)
      font_size 8 do
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
    header += @report.content_product_categories
    header += ['kg ges', 'Netto', 'Brutto', 'R']
    header
  end

  def deliveries_array_by(daily_report)
    res = [deliveries_table_header]
    daily_report.deliveries.each do |delivery|
      row = [delivery.number, delivery.customer.to_s[0..35]]
      products = delivery.products
      row += @report.products.map { |product| products[product.number] }
      row += @report.content_product_categories.map { |cat| delivery.cat_content[cat] }
      row += [
        delivery.total_content,
        nontax_price(delivery.total_price),
        tax_price(delivery.total_price),
        (delivery.on_account ? 'R' : '')
      ]
      res << row
    end
    [false, true, nil].each do |on_account|
      label = on_account ? 'Rechnung' : 'Bar'
      label = ldate(daily_report.day, format: '%d.%m.') if on_account.nil?
      res << sum_row(daily_report, title: label, on_account: on_account)
    end
    res
  end

  def deliveries_table_options
    {
      row_colors:    %w[EEEEEE FFFFFF],
      header:        true,
      width:         bounds.right,
      column_widths: { 0 => 45, 1 => 180 },
      cell_style:    { border_width: 0, padding: [1, 1] }
    }
  end

  def sum_row(daily_report, title: '', on_account: nil)
    res = [title, '']
    count_sums = daily_report.count_sums on_account: on_account
    res += @report.products.map { |product| count_sums[product.number] }
    content_sums = daily_report.content_sums on_account: on_account
    cat_sums = @report.content_product_categories.map { |cat| content_sums[cat] }
    res += cat_sums
    res << cat_sums.compact.sum
    total_price = daily_report.total_price(on_account: on_account)
    res += [nontax_price(total_price), tax_price(total_price), '']
    res
  end

  def write_total_sums
    move_down 15

    font_size 9 do
      table sums_array, sums_table_options do |t|
        t.cells.style { |c| c.align = :right if c.column > 1 }
      end
    end
  end

  def sums_array
    sum_report = @report.sum_report
    [
      sums_table_header,
      sum_row(sum_report, title: 'Bar',      on_account: false),
      sum_row(sum_report, title: 'Rechnung', on_account: true),
      sum_row(sum_report, title: 'Gesamt')
    ]
  end

  def sums_table_options
    {
      row_colors:    %w(dddddd),
      width:         bounds.right,
      column_widths: { 0 => 230, 1 => 10 },
      cell_style:    { border_width: 0, padding: [2, 2], font_style: :bold }
    }
  end

  def sums_table_header
    header = ['', '']
    @report.products.each { |product| header << product.number }
    header += @report.content_product_categories
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
