class AddProductIdToInvoiceItems < ActiveRecord::Migration
  def change
    add_reference :invoice_items, :product, index: true
  end
end
