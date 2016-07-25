require 'prawn/measurement_extensions'

class ReportPdf < ApplicationDocument

  attr_reader :report, :company

  def initialize(report)
    @debug = false
    @margin_top = 28.mm
    @margin_bottom = 28.mm
    @margin_side = 20.mm
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
    number_pages 'Seite <page> von <total>', at: [bounds.right - 150, 0], width: 150, align: :right
    # write_footer
  end

  def write_header
    repeat(:all) do
      height = @margin_top / 2
      bounding_box [0, bounds.top + height], width: bounds.right, height: height do

        text @report.name, size: 18
        text "#{ldate @report.start_date} - #{ldate @report.end_date}", size: 12, style: :italic
        # stroke_bounds if @debug
      end
    end
  end

  def title_text
    "#{@report.name} vom #{ldate @report.start_date} bis #{ldate @report.end_date}"
  end

  def write_report
    first_day = @report.grouped_deliveries[:dates].keys.first
    @report.grouped_deliveries[:dates].each do |date, date_hash|

      start_new_page unless date == first_day
      text ldate(date, format: '%a %d.%m.%Y'), size: 14, style: :bold

      cash_hash = date_hash[:on_account][false]
      on_account_hash = date_hash[:on_account][true]
      header_rows = [0]
      header_rows << (cash_hash[:deliveries].size + 1) if cash_hash && on_account_hash
      sum_rows = [-1]
      sum_rows += [-2, -3] if cash_hash && on_account_hash


      font_size 10 do
        table deliveries_array(date_hash), deliveries_table_options do |t|
          header_rows.each do |row_number|
            t.row(row_number).style background_color: 'dddddd'
            t.row(row_number).font_style = :bold
          end
          sum_rows.each do |row_number|
            t.row(row_number).style background_color: 'dddddd'
            t.row(row_number).font_style = :bold
          end
          t.cells.style { |c| c.align = :right if c.column > 1 }
        end
      end
    end
  end

  def deliveries_table_header(on_account)
    header = []
    header << (on_account ? 'Lieferschein' : 'Quittung')
    header << 'Kunde'
    @report.products.each { |product| header << product }
    header << 'Artikel'
    @report.content_product_categories.each { |category| header << category }
    header += ['kg ges', 'Netto', 'Brutto']
    header
  end

  def deliveries_array(date_hash)
    res = []
    cash_hash = date_hash[:on_account][false]
    on_account_hash = date_hash[:on_account][true]

    date_hash[:on_account].each do |on_account, on_account_hash|
      res << deliveries_table_header(on_account)
      on_account_hash[:deliveries].each { |delivery| res << delivery_array(delivery) }
    end

    res << sum_row(cash_hash, title: 'Bar') if cash_hash
    res << sum_row(on_account_hash, title: 'Rechnung') if on_account_hash
    res << sum_row(date_hash, title: 'Gesamt') if cash_hash && on_account_hash
    res
  end


  def delivery_array(delivery)
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
    del
  end

  def deliveries_table_options
    {
      row_colors:    %w(EEEEEE FFFFFF),
      # header:        true,
      width:         bounds.right,
      column_widths: { 0 => 70, 1 => 170 },
      cell_style:    { border_width: 0, padding: [4, 5] }
    }
  end

  def sum_row(hash, title: '')
    res = [title, '']
    @report.products.each { |product| res << hash[:products][product] }
    res << ''
    @report.content_product_categories.each { |category| res << hash[:content][category] }
    res << hash[:content][:total]
    res << nontax_price(hash[:total_price])
    res << tax_price(hash[:total_price])
    res
  end

  def write_total_sums
    move_down 20
    font_size 10 do
      table sums_array, sums_table_options do |t|
        t.cells.style { |c| c.align = :right if c.column > 1 }
      end
    end
  end

  def sums_array
    res = []
    res << sums_table_header
    res << sum_row(@report.on_account_sums(false), title: 'Barzahler')
    res << sum_row(@report.on_account_sums(true), title: 'auf Rechnung')
    res << sum_row(@report.grouped_deliveries, title: 'Gesamtsumme')
    res
  end

  def sums_table_options
    {
      row_colors:    %w(dddddd),
      width:         bounds.right,
      column_widths: { 0 => 230, 1 => 10 },
      cell_style:    { border_width: 0, padding: [4, 5], font_style: :bold }
    }
  end

  def sums_table_header
    header = ['', '']
    @report.products.each { |product| header << product }
    header << ''
    @report.content_product_categories.each { |category| header << category }
    header += ['kg ges', 'Netto', 'Brutto']
    header
  end

  # def positions_sum_options
  #   {
  #     width: bounds.right,
  #     column_widths: { 1 => 90 },
  #     cell_style: { border_width: 0, padding: [2, 5] }
  #   }
  # end

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
