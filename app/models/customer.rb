class Customer < ActiveRecord::Base
  include PgSearch

  has_many :deliveries, inverse_of: :customer

  multisearchable against: [:salut, :name, :name2, :street, :city, :kind, :invoice_address]

  validates :name, :city, presence: true

  scope :archived, -> { where(archived: true)  }
  scope :active,   -> { where(archived: false) }
end
