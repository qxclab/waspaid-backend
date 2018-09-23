class RemoveValueFromInvoice < ActiveRecord::Migration[5.2]
  def change
    remove_column :invoices, :value
  end
end
