class AddSellerIdToDeliveries < ActiveRecord::Migration
  def change
    change_table :deliveries do |t|
      t.references :seller, index: true
    end
  end
end
