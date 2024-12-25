FactoryBot.define do
  factory :incomes_grath do
    user
    grath_data_this_month { {} }
    grath_data_this_year { {} }
  end
end
