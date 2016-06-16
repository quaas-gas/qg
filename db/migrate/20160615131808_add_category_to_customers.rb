class AddCategoryToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :category, :string
    add_index :customers, :category
  end
end
