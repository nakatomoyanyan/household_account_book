FactoryBot.define do
  factory :user do
    user_name                        {Faker::Internet.username}
    email                           {Faker::Internet.email}
    password                        {'abc1234'}
    password_confirmation           {'abc1234'}
  end
end
