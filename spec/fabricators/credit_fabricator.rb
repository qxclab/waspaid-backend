Fabricator(:credit) do
  description {Faker::Lovecraft.sentence}
  value {Faker::Number.decimal(2)}
  fee {Faker::Number.decimal(2)}
  expired_at {DateTime.tomorrow}
  author {Fabricate(:user)}
  issued {Fabricate(:user)}
end
