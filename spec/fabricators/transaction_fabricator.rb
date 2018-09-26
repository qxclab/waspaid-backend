Fabricator(:transaction) do
  name {Faker::Science.element}
  description {Faker::Lovecraft.sentence}
  invoice {Fabricate(:invoice)}
  value {Faker::Number.decimal(2)}
  transaction_category {Fabricate(:transaction_category, user: User.last)}
end
