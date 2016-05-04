class Customer < ActiveRecord::Base
  validates :name, :city, presence: true
end
