class CreateStocks < ActiveRecord::Migration
  def change
    create_table :stocks do |t|
      t.references :customer, index: true, foreign_key: true
      t.date :date, null: false

      t.timestamps null: false
    end

    add_index :stocks, %i(customer_id date), unique: true
  end
end
