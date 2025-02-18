class IncomesGraphDataJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    Rails.logger.info('IncomesgraphDataJob started')
    current_user = User.find(user_id)
    incomes = current_user.households.income
    incomes_graph_data_this_month = incomes.this_month.joins(:category).group('categories.name').sum(:amount)
    incomes_graph_data_this_year = incomes.this_year.group_by_month(:date, format: '%B').sum(:amount)
    incomes_graph = IncomesGraph.find_or_initialize_by(user: current_user)
    incomes_graph.update!(
      graph_data_this_month: incomes_graph_data_this_month,
      graph_data_this_year: incomes_graph_data_this_year
    )
    Rails.logger.info('IncomesgraphDataJob finished')
  end
end
