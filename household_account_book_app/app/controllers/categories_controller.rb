class CategoriesController < ApplicationController
  before_action :set_user

  def new
    @category = @user.categories.new
  end

  def create
    @category = @user.categories.new(category_params)

    if @category.save
      flash[:notice] = "登録に成功しました" 
      redirect_to user_categories_path(@user)
    else
      flash[:notice] = "登録に失敗しました"
      redirect_to user_categories_path(@user)
    end
  end

  private
  def set_user
    @user = User.find(params[:user_id])
  end

  def category_params
    params.require(:category).permit(:name)
  end
end
