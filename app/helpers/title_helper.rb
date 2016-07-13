module TitleHelper
  def customers_title
    customers_icon title_for_model(Customer)
  end

  def deliveries_title
    delivery_icon title_for_model(Delivery)
  end

  def invoices_title
    invoice_icon title_for_model(Invoice)
  end

end
