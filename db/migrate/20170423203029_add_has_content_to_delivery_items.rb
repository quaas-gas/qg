class AddHasContentToDeliveryItems < ActiveRecord::Migration
  def change
    add_column :delivery_items, :has_content, :boolean
    add_index :delivery_items, :has_content
  end
end
