class AddPendingPayToCredit < ActiveRecord::Migration[5.2]
  def change
    add_column :credits, :pending_money, :decimal
  end
end
