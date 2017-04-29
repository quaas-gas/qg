# RailsSettings Model
class Setting < RailsSettings::Base
  source Rails.root.join('config/app.yml')
  namespace Rails.env

  def self.product_categories!
    self.product_categories = Product.uniq.pluck(:category).sort
  end

  def self.customer_categories!
    self.customer_categories = Customer.uniq.pluck(:category).sort
  end

  def self.customer_regions!
    self.customer_regions = Customer.uniq.pluck(:region).sort
  end
end
