class ChangeProductsContentField < ActiveRecord::Migration
  def change
    change_column :products, :content, 'float USING CAST(content AS float)', default: 0
    # change_column :products, :content, :float, default: 0
  end
end
