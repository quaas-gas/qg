class CreateDeliveries < ActiveRecord::Migration
  def change
    create_table :deliveries do |t|
      t.string :number, unique: true
      t.string :number_show
      t.references :customer, index: true, foreign_key: true
      t.date :date, index: true
      t.string :driver
      t.text :description
      t.string :invoice_number
      t.boolean :on_account
      t.monetize :discount_net
      t.monetize :discount

      t.timestamps null: false
    end
  end
end
