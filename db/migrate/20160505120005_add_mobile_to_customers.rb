class AddMobileToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :mobile, :string
  end
end
