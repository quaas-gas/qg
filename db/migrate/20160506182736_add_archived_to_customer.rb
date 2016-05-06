class AddArchivedToCustomer < ActiveRecord::Migration
  def change
    add_column :customers, :archived, :boolean, default: false
  end
end
