class Delivery < ActiveRecord::Base
  include PgSearch

  belongs_to :customer, inverse_of: :deliveries
  belongs_to :seller, inverse_of: :deliveries

  monetize :discount_net_cents
  monetize :discount_cents

  validates :number, presence: true #, uniqueness: true

  multisearchable against: [:number, :number_show]

  def self.years
    sql = 'SELECT DISTINCT extract(year from date) AS year FROM "deliveries" order by year DESC'
    connection.execute(sql).to_a.map { |year| year['year'] }
  end
end