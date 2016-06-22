class AddInitialStockBalanceToPrices < ActiveRecord::Migration
  def change
    add_column :prices, :initial_stock_balance, :integer, default: 0
  end
end
