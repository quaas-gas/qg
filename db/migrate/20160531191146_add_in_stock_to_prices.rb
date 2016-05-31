class AddInStockToPrices < ActiveRecord::Migration
  def change
    add_column :prices, :in_stock, :boolean, default: true
  end
end
