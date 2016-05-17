class CreateInvoices < ActiveRecord::Migration
  def change
    create_table :invoices do |t|
      t.references :customer, index: true, foreign_key: true
      t.string :number, null: false, unique: true
      t.date :date, index: true
      t.boolean :tax
      t.text :pre_message
      t.text :post_message
      t.text :address
      t.boolean :printed, default: false
      t.jsonb :others

      t.timestamps null: false
    end
  end
end
