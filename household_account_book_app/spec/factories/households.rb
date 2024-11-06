FactoryBot.define do
  factory :household do
    user
    date { Time.current }
    name { 'testhousehold' }
    transaction_type { 1 }
    amount { 1 }
    category
  end
end
