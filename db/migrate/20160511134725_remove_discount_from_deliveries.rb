class RemoveDiscountFromDeliveries < ActiveRecord::Migration
  def change
    change_table :deliveries do |t|
      t.remove :discount_cents, :discount_currency
    end
  end
end
