class AddOthersToDeliveryItems < ActiveRecord::Migration
  def change
    add_column :delivery_items, :others, :jsonb
  end
end
