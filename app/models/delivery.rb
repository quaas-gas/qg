class Delivery < ActiveRecord::Base
  include PgSearch

  belongs_to :customer, inverse_of: :deliveries, required: true
  belongs_to :seller, inverse_of: :deliveries

  has_many :delivery_items

  monetize :discount_cents, with_model_currency: :discount_currency

  validates :number, presence: true #, uniqueness: true

  multisearchable against: [:number, :number_show]

  def self.years
    sql = 'SELECT DISTINCT extract(year from date) AS year FROM "deliveries" order by year DESC'
    connection.execute(sql).to_a.map { |year| year['year'] }
  end

  def currency
    tax ? 'EU4TAX' : 'EU4NET'
  end

  def total_price
    price = Money.from_amount(0, currency)
    total = delivery_items.inject(price) {|sum, item| sum += item.total_price }
    total + discount
  end

end
