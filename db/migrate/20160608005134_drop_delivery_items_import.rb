class DropDeliveryItemsImport < ActiveRecord::Migration
  def up
    drop_table :delivery_items_imports
  end

  def down

  end
end
