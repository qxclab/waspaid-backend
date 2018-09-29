Fabricator(:budget_plan) do
  name {Faker::Bank.account_number}
  value {Faker::Number.decimal(2)}
  budget_item_type {BudgetPlan.budget_item_types.keys.sample}
  transition_type {BudgetPlan.transition_types.keys.sample}
  exact_date nil
  at_date nil
  user {Fabricate(:user)}
end
