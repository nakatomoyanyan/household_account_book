FactoryBot.define do
  factory :user do
    user_name                       {'testuser'}
    email                           {'test@example.com'}
    password                        {'abc1234'}
    password_confirmation           {'abc1234'}
  end
end
