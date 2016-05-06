class Customer < ActiveRecord::Base
  validates :name, :city, presence: true
end

  scope :archived, -> { where(archived: true)  }
  scope :active,   -> { where(archived: false) }
