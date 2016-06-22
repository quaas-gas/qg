class DropStocks < ActiveRecord::Migration
  def up
    remove_foreign_key :stock_items, :products
    remove_foreign_key :stock_items, :stocks
    remove_foreign_key :stocks, :customers

    drop_table :stock_items
    drop_table :stocks
  end

  def down

  end
end
