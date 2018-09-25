class AddCreditInitialValueToCredit < ActiveRecord::Migration[5.2]
  def change
    add_column :credits, :initial_value, :decimal
  end
end
