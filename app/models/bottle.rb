class Bottle < ActiveRecord::Base
  monetize :cert_price_cents, allow_nil: true
  monetize :cert_price_net_cents, allow_nil: true
  monetize :deposit_price_cents, allow_nil: true
  monetize :deposit_price_net_cents, allow_nil: true
  monetize :disposal_price_cents, allow_nil: true
  monetize :disposal_price_net_cents, allow_nil: true

  validates :number, presence: true

end
