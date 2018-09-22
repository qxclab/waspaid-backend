class CreateTransactionCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :transaction_categories do |t|
      t.string :name
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
