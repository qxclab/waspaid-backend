Fabricator(:invoice) do
  name        { Faker::Bank.account_number }
  description { Faker::Bank.name }
  value       { Faker::Number.decimal(2) }
  user        { Fabricate(:user) }
end
