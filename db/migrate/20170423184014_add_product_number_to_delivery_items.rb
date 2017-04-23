class AddProductNumberToDeliveryItems < ActiveRecord::Migration
  def change
    add_column :delivery_items, :product_number, :string
    add_index :delivery_items, :product_number
  end
end
