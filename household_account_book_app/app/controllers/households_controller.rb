class HouseholdsController < ApplicationController
  include UserResourceConcern
  def index
    @household = Household.new
    @financial_summary_this_year = current_user.households.financial_summary_this_year
    @financial_summary_this_month = current_user.households.financial_summary_this_month
    @years_months = current_user.households.distinct_years_months
    @q = current_user.households.ransack(params[:q])
    @households = @q.result
                    .eager_load(:category)
                    .order(date: :desc, id: :asc)
                    .page(params[:page])
                    .per(50)
    @total_amount_households = @households.sum(:amount)
  end

  def create
    @household = current_user.households.new(household_params)
    if @household.save
      flash[:notice] = '登録に成功しました'
      redirect_to households_path(current_user)
    else
      flash[:notice] = '登録に失敗しました'
      render 'index', status: :unprocessable_entity
    end
  end

  def income
    incomes = current_user.households.income
    @incomes_this_year = incomes.this_year.eager_load(:category).decorate
    @incomes_grath_data_this_month = incomes.this_month.joins(:category).group('categories.name').sum(:amount)
    @incomes_grath_data_this_year = incomes.this_year.group_by_month(:date, format: '%B').sum(:amount)
  end

  def expense
    households = current_user.households
    @all_expenses_this_year = households.all_expense.this_year.eager_load(:category).decorate
    @all_expenses_grath_data_this_month = households.all_expense.this_month.joins(:category).group('categories.name').sum(:amount)
    @fixed_expenses_grath_data_this_month = households.fixed_expense.this_month.joins(:category).group('categories.name').sum(:amount)
    @variable_expenses_grath_data_this_month = households.variable_expense.this_month.joins(:category).group('categories.name').sum(:amount)
    fixed_expenses_data = households.fixed_expense.this_year.group_by_month(:date, format: '%B').sum(:amount)
    variable_expenses_data = households.variable_expense.this_year.group_by_month(:date, format: '%B').sum(:amount)
    @expenses_grath_data_this_year = [{ name: '固定費', data: fixed_expenses_data },
                                      { name: '流動費', data: variable_expenses_data }]
  end

  private

  def household_params
    params.require(:household).permit(:name, :date, :amount, :category_id, :transaction_type)
  end
end
