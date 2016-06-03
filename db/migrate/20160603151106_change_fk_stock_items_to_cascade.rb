class ChangeFkStockItemsToCascade < ActiveRecord::Migration
  def up
    remove_foreign_key :stock_items, :stocks
    add_foreign_key    :stock_items, :stocks, on_delete: :cascade
  end

  def down
  end
end
