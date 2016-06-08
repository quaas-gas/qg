class RemoveContractorFromCustomers < ActiveRecord::Migration
  def change
    remove_column :customers, :price_in_net
    remove_column :customers, :contractor
    remove_column :customers, :own_customer
  end
end
