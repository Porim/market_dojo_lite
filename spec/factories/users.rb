FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.unique.email }
    password { "password123" }
    company_name { Faker::Company.name }
    phone { Faker::PhoneNumber.phone_number }
    role { "buyer" }

    trait :buyer do
      role { "buyer" }
    end

    trait :supplier do
      role { "supplier" }
    end
  end
end
