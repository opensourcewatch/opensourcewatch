Fabricator(:ruby_gem) do
  url       { Faker::Internet.url }
  downloads { Faker::Number.between(1, 5000000) }
  name      { Faker::Name.name }
  stars     { Faker::Number.between(1, 50000) }
  description { Faker::Lorem.paragraph(10) }
end
