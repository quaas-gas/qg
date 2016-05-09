class Seller < ActiveRecord::Base


  validates :first_name, :last_name, :short, presence: true

  def name
    "#{first_name} #{last_name}"
  end

end
