class HouseholdsController < ApplicationController
  include UserResourceController
  def index
    @household = Household.new
  end

  def create
    @household = user.households.new(household_params)

    flash[:notice] = if @household.save
                       '登録に成功しました'
                     else
                       '登録に失敗しました'
                     end
    redirect_to user_households_path(user)
  end

  private

  def household_params
    params.require(:household).permit(:name, :date, :amount, :category_id, :transaction_type)
  end
end
