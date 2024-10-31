class HouseholdsController < ApplicationController
  include UserResourceConcern
  def index
    @household = Household.new
    @total_income_this_year = Household.total_income_this_year
    @total_expense_this_year = Household.total_expense_this_year
    @net_balance_this_year = Household.net_balance_this_year
    @total_income_this_month = Household.total_income_this_month
    @total_expense_this_month = Household.total_expense_this_month
    @net_balance_this_month = Household.net_balance_this_month
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

  private

  def household_params
    params.require(:household).permit(:name, :date, :amount, :category_id, :transaction_type)
  end
end
