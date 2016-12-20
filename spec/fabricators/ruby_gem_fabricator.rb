Fabricator(:ruby_gem) do
  url { Faker::Internet.url }
  downloads { Faker::Number.between(1, 50000)}
  name { Faker::Name.name }
end
