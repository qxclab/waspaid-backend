class CreateInvoices < ActiveRecord::Migration[5.2]
  def change
    create_table :invoices do |t|
      t.string :name
      t.string :description
      t.decimal :value
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
