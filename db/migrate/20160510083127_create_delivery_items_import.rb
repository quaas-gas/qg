class CreateDeliveryItemsImport < ActiveRecord::Migration
  def change
    create_table :delivery_items_imports do |t|
      t.string :delivery_id
      t.string :bottle_id
      t.integer :count_full
      t.integer :count_empty
      t.integer :stock_new
      t.float :total_kg
      t.float :price
      t.float :price_net
      t.float :price_total
      t.float :price_total_net
    end
  end
end
# <delivery_id>n10875</delivery_id>
# <bottle_id>bg05</bottle_id>
# <count_full>6</count_full>
# <count_empty>6</count_empty>
# <stock_new>0</stock_new>
# <total_kg>30</total_kg>
# <price>6.7</price>
# <price_net>5.7759</price_net>
# <price_total>40.2</price_total>
# <price_total_net>34.6554</price_total_net>
