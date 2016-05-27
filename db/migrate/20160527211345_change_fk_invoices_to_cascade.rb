class ChangeFkInvoicesToCascade < ActiveRecord::Migration
  def up
    remove_foreign_key :invoice_items, :invoices
    add_foreign_key    :invoice_items, :invoices, on_delete: :cascade
  end

  def down
  end
end
