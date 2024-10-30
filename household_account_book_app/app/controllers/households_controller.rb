class HouseholdsController < ApplicationController
  before_action :authorize_user

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

  def user
    @user ||= User.find(params[:user_id])
  end

  def household_params
    params.require(:household).permit(:name, :date, :amount, :category_id, :transaction_type)
  end

  def authorize_user
    return if user == current_user

    flash[:notice] = 'アクセス権限がありません'
    redirect_to root_path
  end
end
