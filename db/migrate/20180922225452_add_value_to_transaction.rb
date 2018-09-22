class AddValueToTransaction < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :value, :decimal
  end
end
