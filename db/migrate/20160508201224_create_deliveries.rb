class CreateDeliveries < ActiveRecord::Migration
  def change
    create_table :deliveries do |t|
      t.string :number, unique: true
      t.string :number_show
      t.references :customer, index: true, foreign_key: true
      t.references :seller, index: true
      t.date :date, index: true
      t.string :driver
      t.text :description
      t.string :invoice_number
      t.boolean :tax, default: true
      t.boolean :on_account
      t.monetize :discount
      t.jsonb :others

      t.timestamps null: false
    end
  end
end
