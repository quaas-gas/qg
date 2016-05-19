class AddInvoiceIdToDeliveries < ActiveRecord::Migration
  def change
    add_reference :deliveries, :invoice, index: true
  end
end
