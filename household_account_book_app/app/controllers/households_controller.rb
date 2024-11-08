class HouseholdsController < ApplicationController
  include UserResourceConcern
  def index
    @household = Household.new
    @financial_summary_this_year = current_user.households.financial_summary_this_year
    @financial_summary_this_month = current_user.households.financial_summary_this_month
  end

  def create
    @household = user.households.new(household_params)
    if @household.save
      flash[:notice] = '登録に成功しました'
      redirect_to user_households_path(user)
    else
      flash[:notice] = '登録に失敗しました'
      render 'index', status: :unprocessable_entity
    end
  end

  def income
    @incomes_this_year = current_user.households.income.this_year
    @incomes_grath_data_this_year = current_user.households.income.this_year.group_by_month(:date, format: '%B').sum(:amount)
    @incomes_grath_data_this_month = current_user.households.income.this_month.group(:name).sum(:amount)
  end

  private

  def household_params
    params.require(:household).permit(:name, :date, :amount, :category_id, :transaction_type)
  end
end
