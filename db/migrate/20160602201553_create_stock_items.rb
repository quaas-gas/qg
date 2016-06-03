class CreateStockItems < ActiveRecord::Migration
  def change
    create_table :stock_items do |t|
      t.references :stock, index: true, foreign_key: true
      t.references :product, index: true, foreign_key: true
      t.integer :count, null: false, default: 0

      t.timestamps null: false
    end
  end
end
