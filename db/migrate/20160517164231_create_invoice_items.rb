class CreateInvoiceItems < ActiveRecord::Migration
  def change
    create_table :invoice_items do |t|
      t.references :invoice, index: true, foreign_key: true
      t.integer :position
      t.integer :count
      t.string :name, null: false
      t.monetize :unit_price

      t.jsonb :others

      t.timestamps null: false
    end
  end
end
