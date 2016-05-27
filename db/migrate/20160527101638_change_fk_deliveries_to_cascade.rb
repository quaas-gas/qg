class ChangeFkDeliveriesToCascade < ActiveRecord::Migration
  def up
    remove_foreign_key :delivery_items, :deliveries
    add_foreign_key    :delivery_items, :deliveries, on_delete: :cascade
  end

  def down
  end
end
