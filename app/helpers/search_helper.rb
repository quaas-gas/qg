module SearchHelper
  def display_name_for(customer)
    [customer.salut, customer.name, customer.name2, customer.city].select(&:present?).join(' ')
  end
end
