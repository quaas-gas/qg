class AddActiveToPrices < ActiveRecord::Migration
  def change
    add_column :prices, :active, :boolean, default: true
  end
end
