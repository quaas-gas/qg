class CreateDeliveryItems < ActiveRecord::Migration
  def change
    create_table :delivery_items do |t|
      t.references :delivery, index: true, foreign_key: true
      t.references :product, index: true
      t.string :name
      t.integer :count
      t.integer :count_back
      t.monetize :unit_price

      t.timestamps null: false
    end
  end
end
