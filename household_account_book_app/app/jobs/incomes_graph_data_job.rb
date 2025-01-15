class IncomesGraphDataJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    Rails.logger.info('IncomesGrathDataJob started')
    current_user = User.find(user_id)
    incomes = current_user.households.income
    incomes_grath_data_this_month = incomes.this_month.joins(:category).group('categories.name').sum(:amount)
    incomes_grath_data_this_year = incomes.this_year.group_by_month(:date, format: '%B').sum(:amount)
    incomes_grath = IncomesGrath.find_or_initialize_by(user: current_user)
    incomes_grath.update!(
      grath_data_this_month: incomes_grath_data_this_month,
      grath_data_this_year: incomes_grath_data_this_year
    )
    Rails.logger.info('IncomesGrathDataJob finished')
  end
end
