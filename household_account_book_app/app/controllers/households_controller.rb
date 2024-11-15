class HouseholdsController < ApplicationController
  include UserResourceConcern
  def index
    @household = Household.new
    @financial_summary_this_year = current_user.households.financial_summary_this_year
    @financial_summary_this_month = current_user.households.financial_summary_this_month
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
    @incomes_this_year = incomes.this_year
    @incomes_grath_data_this_year = @incomes_this_year.group_by_month(:date, format: '%B').sum(:amount)
    @incomes_grath_data_this_month = incomes.this_month.group(:name).sum(:amount)
  end

  def expense
    expenses = current_user.households.expense
    @expenses_this_year = expenses.this_year.decorate
  end

  private

  def household_params
    params.require(:household).permit(:name, :date, :amount, :category_id, :transaction_type)
  end
end
