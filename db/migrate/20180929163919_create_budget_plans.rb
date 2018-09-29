class CreateBudgetPlans < ActiveRecord::Migration[5.2]
  def change
    create_table :budget_plans do |t|
      t.string :name
      t.decimal :value
      t.integer :budget_item_type, default: 0
      t.integer :transition_type, default: 0
      t.integer :at_date
      t.datetime :exact_date
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
