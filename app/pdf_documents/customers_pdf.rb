require 'prawn/measurement_extensions'

class CustomersPdf < ApplicationDocument

  attr_reader :customers, :filter

  def initialize(customers, filter)
    @debug = false
    @margin_top = 20.mm
    @margin_bottom = 20.mm
    @margin_side = 20.mm
    super(page_size: 'A4', page_layout: :landscape, margin: [@margin_top, @margin_side, @margin_bottom])
    @customers = customers
    @filter = filter
    generate
  end

  def filename
    "#{Customer.model_name.human(count: 2)}.pdf"
  end

  def generate
    stroke_bounds if @debug
    write_header
    write_customers_table
  end

  def write_header
    title = "#{@customers.count} #{Customer.model_name.human count: @customers.count}"
    text title, size: 18, style: :bold
    title = %i(city region category).each_with_object([]) do |type, arr|
      arr << filter.send(type)
    end
    title << 'Archiv' if filter.archived
    text title.reject(&:blank?).join(', '), size: 12
  end

  def write_customers_table
    font_size 8 do
      table customers_headers + customers_array, customers_table_options do |t|
        t.row(0).style background_color: 'dddddd'
        t.row(0).font_style = :bold
        t.cells.style { |c| c.align = :right if c.column == 0 }
      end
    end
  end

  def customers_headers
    [[
      Customer.human_attribute_name(:id),
      Customer.human_attribute_name(:name),
      '',
      Customer.human_attribute_name(:city),
      Customer.human_attribute_name(:street),
      Customer.human_attribute_name(:zip),
      Customer.human_attribute_name(:phone),
      Customer.human_attribute_name(:category),
      Customer.human_attribute_name(:region),
    ]]
  end

  def customers_array
    customers.map do |c|
      [
        c.id,
        [c.salut, c.name].reject(&:blank?).join(' '),
        c.name2,
        c.city,
        c.street,
        c.zip,
        c.phone,
        c.category,
        c.region]
    end
  end

  def customers_table_options
    {
      row_colors:    %w(EEEEEE FFFFFF),
      header:        true,
      width:         bounds.right,
      column_widths: { 0 => 25, 1 => 170, 5 => 30, 7 => 100, 8 => 70 },
      cell_style:    { border_width: 0, padding: [3, 3] }
    }
  end

end
