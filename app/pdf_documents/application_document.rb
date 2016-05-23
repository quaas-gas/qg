class ApplicationDocument < Prawn::Document

  def initialize(options = {}, &block)
    super(options, &block)
  end

  def ldate(date, options = nil)
    return '' unless date.present?
    I18n.l date, options
  end

  # def right_align_cell(content)
  #   Prawn::Table::Cell::Text.make(self, content, align: :right)
  # end

  def display_price(money)
    currency = money.currency.to_s.sub 'EU4', 'EUR'
    money.exchange_to(currency).format
  end
end
