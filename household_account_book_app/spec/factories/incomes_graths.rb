FactoryBot.define do
  factory :incomes_graph do
    user
    graph_data_this_month { {} }
    graph_data_this_year { {} }
  end
end
