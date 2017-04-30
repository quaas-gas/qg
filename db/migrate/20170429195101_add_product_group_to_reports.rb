class AddProductGroupToReports < ActiveRecord::Migration
  def change
    add_column :reports, :product_group, :string
  end
end
