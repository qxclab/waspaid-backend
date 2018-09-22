class CreateTransactions < ActiveRecord::Migration[5.2]
  def change
    create_table :transactions do |t|
      t.string :name
      t.string :description
      t.references :invoice, foreign_key: true
      t.references :transaction_category, foreign_key: true

      t.timestamps
    end
  end
end
