FactoryGirl.define do
  factory(:user) do
    sequence(:name) { |n| "user_#{n}" }
    sequence(:username) { |n| "username#{n}" }
    sequence(:email) { |n| "user#{n}@example.com" }
    password '123456'
  end
end