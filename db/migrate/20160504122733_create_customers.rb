class CreateCustomers < ActiveRecord::Migration
  def change
    create_table :customers do |t|
      t.string :salut
      t.string :name, null: false
      t.string :name2
      t.boolean :own_customer, default: true
      t.string :street
      t.string :city
      t.string :zip
      t.string :phone
      t.string :email
      t.boolean :gets_invoice, default: true
      t.string :region
      t.string :kind
      t.boolean :price_in_net, default: true
      t.boolean :has_stock, default: false
      t.date :last_stock_date
      t.text :invoice_address

      t.timestamps null: false
    end
  end
end
