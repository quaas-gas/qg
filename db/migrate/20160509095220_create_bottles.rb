class CreateBottles < ActiveRecord::Migration
  def change
    create_table :bottles do |t|
      t.string :number, null: false
      t.string :gas
      t.string :size
      t.string :name
      t.string :content
      t.monetize :cert_price
      t.monetize :cert_price_net
      t.monetize :deposit_price
      t.monetize :deposit_price_net
      t.monetize :disposal_price
      t.monetize :disposal_price_net

      t.timestamps null: false
    end
  end
end
