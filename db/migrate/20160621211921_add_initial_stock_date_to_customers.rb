class AddInitialStockDateToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :initial_stock_date, :date
  end
end
