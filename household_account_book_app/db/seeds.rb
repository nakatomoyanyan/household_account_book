require 'faker'

user = User.create!(user_name: 'nakatomotest', email: "nakatomotest@example.com", password: "nakatomotest", password_confirmation: "nakatomotest")

income_categories_names = ["給料", "メルカリ", "youtube", "物販", "アルバイト"]
expense_categories_names = ["食費", "交通費", "交際費", "書籍", "雑貨"]

income_categories = (1..5).map do |id|
  Category.create!(
    id: id,
    user: user,
    name: income_categories_names[id - 1]
  )
end

expense_categories = (6..10).map do |id|
  Category.create!(
    id: id,
    user: user,
    name: expense_categories_names[id - 6]
  )
end

(1..12).each do |month|
  100.times do
    Household.create!(
      user: user,
      date: Date.new(2025, month, rand(1..28)),
      transaction_type: 0,
      category_id: income_categories.sample.id,
      amount: rand(1_000..10_000)
    )
  end

  100.times do
    Household.create!(
      user: user,
      date: Date.new(2025, month, rand(1..28)),
      transaction_type: [1, 2].sample, 
      category_id: expense_categories.sample.id,
      amount: rand(100..1_000)
    )
  end
end
