class AddCategoryToProduct < ActiveRecord::Migration
  def change
    change_table :products do |t|
      t.string :category
    end
    add_index :products, :category
  end
end
