Fabricator(:credit) do
  description {Faker::Lovecraft.sentence}
  value {rand(10...1000).to_f}
  fee {rand(10...1000).to_f}
  expired_at {DateTime.tomorrow}
  author {Fabricate(:user)}
  issued {Fabricate(:user)}
end
