class AddContractorToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :contractor, :string
    add_index :customers, :contractor
  end
end
