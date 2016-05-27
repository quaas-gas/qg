class Delivery < ActiveRecord::Base
  include PgSearch

  belongs_to :customer, inverse_of: :deliveries, required: true
  belongs_to :seller, inverse_of: :deliveries
  belongs_to :invoice, inverse_of: :deliveries

  has_many :items, class_name: 'DeliveryItem', inverse_of: :delivery

  validates :number, :date, presence: true #, uniqueness: true

  multisearchable against: [:number, :number_show]

  accepts_nested_attributes_for :items,
                                allow_destroy: true,
                                reject_if: lambda { |attributes|
                                  attributes['count'].blank? || attributes['unit_price'].blank?
                                }

  scope :on_account, -> { where on_account: true }

  def self.years
    sql = 'SELECT DISTINCT extract(year from date) AS year FROM "deliveries" order by year DESC'
    connection.execute(sql).to_a.map { |year| year['year'] }
  end

  def currency
    tax ? 'EU4TAX' : 'EU4NET'
  end

  def total_articles
    items.map(&:count).sum
  end

  def total_price
    items.map(&:total_price).sum
  end

end
