class CreateCredits < ActiveRecord::Migration[5.2]
  def change
    create_table :credits do |t|
      t.string :description
      t.string :state
      t.references :author, references: :user, index: true
      t.references :issued, references: :user, index: true
      t.decimal :value
      t.decimal :fee
      t.datetime :expired_at

      t.timestamps
    end
  end
end
