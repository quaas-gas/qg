module IconHelper
  def customers_icon(text = nil)
    fa_icon 'users', text: text
  end

  def customer_icon(text = nil)
    fa_icon 'user', text: text
  end

  def customer_type_icon(customer, text = nil)
    fa_icon (customer.gets_invoice ? 'list-alt' : 'eur'), text: text
  end

  def delivery_icon(text = nil)
    fa_icon 'truck', text: text
  end

  def delivery_type_icon(delivery, text = nil)
    fa_icon (delivery.on_account ? 'list-alt' : 'eur'), text: text
  end

  def invoice_icon(text = nil)
    fa_icon 'file', text: text
  end

  def stock_icon(text = nil)
    fa_icon 'line-chart', text: text
  end

end
