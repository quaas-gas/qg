class ChangeFkStocksToCascade < ActiveRecord::Migration
  def up
    remove_foreign_key :stocks, :customers
    add_foreign_key    :stocks, :customers, on_delete: :cascade
  end

  def down
  end
end
