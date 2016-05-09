module SearchHelper
  def display_name_for(result)
    case result
    when Customer
      [result.salut, result.name, result.name2, result.city].select(&:present?).join(' ')
    when Delivery
      [result.number_show, ldate(result.date), result.customer.name].select(&:present?).join(' ')
    end
  end
end
