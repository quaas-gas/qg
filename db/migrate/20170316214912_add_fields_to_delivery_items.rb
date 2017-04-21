class AddFieldsToDeliveryItems < ActiveRecord::Migration
  def change
    change_table :delivery_items do |t|
      t.string :product_category, default: '', index: true
      t.string :product_group, default: '', index: true
      t.monetize :total_price
      t.integer :total_content_in_g
    end
  end
end
