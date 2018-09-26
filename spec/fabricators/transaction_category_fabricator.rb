Fabricator(:transaction_category) do
  name {Faker::Science.element}
  user {Fabricate(:user)}
end
